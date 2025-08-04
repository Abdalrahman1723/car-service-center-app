import 'package:flutter/material.dart';
import 'package:timelines_plus/timelines_plus.dart';

class TimeLine extends StatelessWidget {
  const TimeLine({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Timeline.tileBuilder(
        builder: TimelineTileBuilder.fromStyle(
          
          contentsAlign: ContentsAlign.alternating,
          contentsBuilder: (context, index) => Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text('Timeline Event $index'),
          ),
          itemCount: 10,
        ),
      ),
    );
  }
}
