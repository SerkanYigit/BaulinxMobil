/* import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    init();

    super.initState();
  }

  init() async {
    _myData = await getFilesData(null);
    setState(() {});
  }

  List<FileModel>? _myData;

  /// Get url data using api or anyway you want
  Future<List<FileModel>?> getFilesData(String? parentId) async {
    var response = await http.get(
        Uri.parse('yourBaseUrl.api/file/tree?parentId=${parentId ?? ''}&skip=0'
            '&count=0'),
       );
    Map<String, dynamic> json = jsonDecode(response.body);
    return List<FileModel>.from(json['data'].map((e) => FileModel.fromJson(e)));
  }

  Future<String> uploadFile(
      String? folderId, Uint8List? pickedFile, String? pickedFileName) async {
    var request = http.MultipartRequest(
        "POST",
        Uri.parse('yourBaseUrl.api/storage/folder/file/admin'));
       request.files.add(http.MultipartFile.fromBytes(
      'file',
      pickedFile!,
      filename: pickedFileName,
      contentType: MediaType("image", pickedFileName!.split('.').last),
    ));
    request.fields['name'] = pickedFileName;
    request.headers["Content-Type"] = "image/jpg";
    request.fields['path'] = 'img';
    request.fields['type'] = 'File';
    request.fields['parentId'] = folderId!;

    var response = await request.send();
    var data = await response.stream.toBytes();
    String dataString = utf8.decode(data);
    var r = json.decode(dataString);
    return r['data']['thumbnailUrl'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_myData != null)
              SimpleFileManager(
                filesList: _myData!,
                uploadButtonText: 'Upload',
                onUpload: (String? parentId, pickedFile,
                    String? pickedFileName) async {
                  if (pickedFile != null) {
                    return await uploadFile(
                        parentId, pickedFile, pickedFileName);
                  } else {
                    return null;
                  }
                },
                onCreateFolderClicked: (String? parentID) {},
                onBack: (String? value) async {
                  print(value);
                  return await getFilesData(value);
                },
                onFolderClicked: (value) async {
                  return await getFilesData(value!.id);
                },
                placeholderFromAssets: 'assets/images/placeholder.png',
              ),
          ],
        ),
      ),
    );
  }
} */

import 'package:expandable_tile/expandable_tile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const Example());
}

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Expanded Tile Example',
      home: ExpandedPage(),
    );
  }
}

class ExpandedPage extends StatefulWidget {
  const ExpandedPage({super.key});

  @override
  State<ExpandedPage> createState() => _ExpandedPageState();
}

class _ExpandedPageState extends State<ExpandedPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget expandImage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("None animation",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.noneAnimation(
            src:
                "https://www.centrale-canine.fr/sites/default/files/2024-11/Fiche%20de%20race%20banni%C3%A8re%20corgi%20pembroke.jpg",
            child: const Text(
                "This is demo for expand image without animation. The Child is Text"),
          ),
        ),
        const Text("Vertical position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.animatedDef(
            src:
                "https://www.centrale-canine.fr/sites/default/files/2024-11/Fiche%20de%20race%20banni%C3%A8re%20corgi%20pembroke.jpg",
            child: const Text(
                "This is demo for expand image with default animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.animatedFade(
            src:
                "https://file.hstatic.net/1000292100/article/61312315_440746569804333_4727353524977926144_n_9a585e47ace64345af4b2dd9bc1f45bb.jpg",
            child: const Text(
                "This is demo for expand image with fade animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.animatedScale(
            src:
                "https://file.hstatic.net/1000292100/file/img_1907_grande_e05accd5a03247069db4f3169cfb8b11_grande.jpg",
            child: const Text(
                "This is demo for expand image with scale animation. The Child is Text"),
          ),
        ),
        const Text("Horizontal position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.animatedFade(
            posHorizontal: true,
            src:
                "https://file.hstatic.net/1000292100/article/61312315_440746569804333_4727353524977926144_n_9a585e47ace64345af4b2dd9bc1f45bb.jpg",
            child: const Text(
                "This is demo for expand image with fade animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableImageView.animatedScale(
            posHorizontal: true,
            src:
                "https://file.hstatic.net/1000292100/file/img_1907_grande_e05accd5a03247069db4f3169cfb8b11_grande.jpg",
            child: const Text(
                "This is demo for expand image with scale animation. The Child is Text"),
          ),
        ),
      ],
    );
  }

  Widget expandableText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text("None animation",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.noneAnimation(
            title: "No animation",
            child: const Text(
                "This is demo for expand text without animation. The Child is Text"),
          ),
        ),
        const Text("Vertical position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedDef(
            title: "Animation default vertical",
            child: const Text(
                "This is demo for expand text vertical. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedDef(
            axis: AxisExpand.horizontal,
            title: "Animation default horizontal",
            child: const Text(
                "This is demo for expand text horizontal. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedFade(
            title: "Animation fade",
            child: const Text(
                "This is demo for expand text with animation fading in and out!"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedScale(
            title: "Animation scale",
            child: const Text(
                "This is demo for expand text with scaling animation!"),
          ),
        ),
        const Text("Horizontal position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedDef(
            axis: AxisExpand.horizontal,
            posHorizontal: true,
            title: "Animation default horizontal",
            child: const Text(
                "This is demo for expand text horizontal with horizontal position. The Child is Text and Image"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedDef(
            posHorizontal: true,
            title: "Animation default vertical",
            child: const Text(
                "This is demo for expand text vertical with horizontal position. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedScale(
            posHorizontal: true,
            title: "Animation scale",
            child: const Text(
                "This is demo for expand text with scaling animation!"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableTileView.animatedFade(
            posHorizontal: true,
            title: "Animation fade",
            child: const Text(
                "This is demo for expand text with animation fading in and out!"),
          ),
        ),
      ],
    );
  }

  Widget expandableCustom() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("None animation",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.noneAnimation(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "No animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand custom title without animation. The Child is Text"),
          ),
        ),
        const Text("Vertical position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.animatedDef(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "Default animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand custom with default animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.animatedFade(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "Fade animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand custom with fade animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.animatedScale(
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "Scale animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand image with scale animation. The Child is Text"),
          ),
        ),
        const Text("Horizontal position",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.deepOrange)),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.animatedFade(
            posHorizontal: true,
            ratio: const Ratio(7, 3),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "Fade animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand image with fade animation. The Child is Text"),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 5.0),
          child: ExpandableCustomView.animatedScale(
            posHorizontal: true,
            ratio: const Ratio(7, 3),
            title: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Custom Title",
                  style: TextStyle(fontSize: 14, color: Colors.redAccent),
                ),
                Text(
                  "Scale animation",
                  style: TextStyle(fontSize: 14, color: Colors.green),
                ),
                Icon(Icons.check, size: 27, color: Colors.redAccent),
              ],
            ),
            child: const Text(
                "This is demo for expand image with scale animation. The Child is Text"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Demo Expandable Tile")),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExpandableTileView.animatedDef(
                  title: "Demo expandable text", child: expandableText()),
              Container(
                child: Text("sdfsdf"),
                color: Colors.amber,
              )
            ],
          ),
        ),
      ),
    );
  }
}
