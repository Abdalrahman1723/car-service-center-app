import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../shared/models/debt_transaction.dart';
import '../../../../../../core/constants/app_strings.dart';
import '../../../../manager/features/debt_management/domain/usecases/settle_supplier_debt.dart';
import '../../../../manager/features/debt_management/data/datasources/debt_transaction_datasource.dart';
import '../../../../manager/features/vault/data/repositories/vault_repository_impl.dart';
import '../../../../manager/features/vault/domain/usecases/add_vault_transaction.dart';
import '../../data/datasources/supplier_datasource.dart';
import '../../domain/entities/supplier.dart';

class SupplierDebtSettlementDialog extends StatefulWidget {
  final SupplierEntity supplier;
  final VoidCallback onSettlementComplete;

  const SupplierDebtSettlementDialog({
    super.key,
    required this.supplier,
    required this.onSettlementComplete,
  });

  static Future<void> show(
    BuildContext context,
    SupplierEntity supplier,
    VoidCallback onSettlementComplete,
  ) {
    return showDialog(
      context: context,
      builder: (context) => SupplierDebtSettlementDialog(
        supplier: supplier,
        onSettlementComplete: onSettlementComplete,
      ),
    );
  }

  @override
  State<SupplierDebtSettlementDialog> createState() =>
      _SupplierDebtSettlementDialogState();
}

class _SupplierDebtSettlementDialogState
    extends State<SupplierDebtSettlementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DebtTransactionType _selectedType = DebtTransactionType.supplierPayment;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.supplier.balance.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _processSettlement() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final amount = double.parse(_amountController.text);
      final notes = _notesController.text.trim();

      final settleDebt = SettleSupplierDebt(
        debtDataSource: FirebaseDebtTransactionDataSource(),
        supplierDataSource: SupplierDataSource(FirebaseFirestore.instance),
        addVaultTransaction: AddVaultTransaction(VaultRepositoryImpl()),
      );

      await settleDebt.execute(
        supplier: widget.supplier,
        amount: amount,
        transactionType: _selectedType,
        notes: notes.isNotEmpty ? notes : null,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSettlementComplete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تسوية الدين بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تسوية دين المورد: ${widget.supplier.name}'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current Balance Display
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      color: Colors.red.shade700,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'الدين الحالي:',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.red.shade700),
                          ),
                          Text(
                            '${widget.supplier.balance.toStringAsFixed(2)} ${AppStrings.currency}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Transaction Type Selection
              Text(
                'نوع العملية:',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<DebtTransactionType>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                items: [
                  DropdownMenuItem(
                    value: DebtTransactionType.supplierPayment,
                    child: const Text('دفع للمورد'),
                  ),
                  DropdownMenuItem(
                    value: DebtTransactionType.supplierReceipt,
                    child: const Text('استلام للمورد'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Amount Input
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'المبلغ المدفوع',
                  border: OutlineInputBorder(),
                  suffixText: AppStrings.currency,
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى إدخال المبلغ';
                  }
                  final amount = double.tryParse(value);
                  if (amount == null || amount <= 0) {
                    return 'يرجى إدخال مبلغ صحيح';
                  }
                  if (amount > widget.supplier.balance) {
                    return 'المبلغ أكبر من الدين الحالي';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Notes Input
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات (اختياري)',
                  border: OutlineInputBorder(),
                  hintText: 'أضف ملاحظات حول العملية...',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _processSettlement,
          child: _isProcessing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('تسوية الدين'),
        ),
      ],
    );
  }
}
