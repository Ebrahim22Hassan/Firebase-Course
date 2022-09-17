import 'package:flutter/material.dart';

class ViewNotes extends StatefulWidget {
  final dynamic notes;

  const ViewNotes({Key? key, this.notes}) : super(key: key);

  @override
  State<ViewNotes> createState() => _ViewNotesState();
}

class _ViewNotesState extends State<ViewNotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Notes'),
      ),
      body: Column(
        children: [
          Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "${widget.notes['title']}",
                style: Theme.of(context).textTheme.headline5,
              )),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.network(
              "${widget.notes['imageUrl']}",
              width: double.infinity,
              height: 300,
              fit: BoxFit.fill,
            ),
          ),
          Container(
              margin: const EdgeInsets.symmetric(vertical: 15),
              child: Text(
                "${widget.notes['note']}",
                style: Theme.of(context).textTheme.bodyText2,
              )),
        ],
      ),
    );
  }
}
