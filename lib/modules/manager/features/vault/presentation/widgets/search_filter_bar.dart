import 'package:flutter/material.dart';

class SearchFilterBar extends StatefulWidget {
  final Function(String) onSearch;
  final Function(DateTime?, DateTime?) onFilter;

  const SearchFilterBar({
    super.key,
    required this.onSearch,
    required this.onFilter,
  });

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(labelText: 'Search'),
              onChanged: widget.onSearch,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              // Show date range picker
              final range = await showDateRangePicker(
                context: context,
                firstDate: DateTime(2000),
                lastDate: DateTime.now(),
              );
              widget.onFilter(range?.start, range?.end);
            },
          ),
        ],
      ),
    );
  }
}
