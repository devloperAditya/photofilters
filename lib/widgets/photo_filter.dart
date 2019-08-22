import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:image/image.dart' as imageLib;
import 'package:path_provider/path_provider.dart';

class PhotoFilter extends StatelessWidget {
  final imageLib.Image image;
  final String filename;
  final Filter filter;
  final BoxFit fit;
  final Widget loader;
  PhotoFilter({
    @required this.image,
    @required this.filename,
    @required this.filter,
    this.fit = BoxFit.fill,
    this.loader = const Center(child: CircularProgressIndicator()),
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<int>>(
      future: compute(applyFilter, <String, dynamic>{
        "filter": filter,
        "image": image,
        "filename": filename,
      }),
      builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return loader;
          case ConnectionState.active:
          case ConnectionState.waiting:
            return loader;
          case ConnectionState.done:
            if (snapshot.hasError)
              return Center(child: Text('Error: ${snapshot.error}'));
            return Image.memory(
              snapshot.data,
              fit: fit,
            );
        }
        return null; // unreachable
      },
    );
  }
}

///The PhotoFilterSelector Widget for apply filter from a selected set of filters
class PhotoFilterSelector extends StatefulWidget {
  final Widget title;

  final List<Filter> filters;
  final imageLib.Image image;
  final Widget loader;
  final BoxFit fit;
  final String filename;
  final bool circleShape;


  const PhotoFilterSelector({
    Key key,
    @required this.title,
    @required this.filters,
    @required this.image,
    this.loader = const Center(child: CircularProgressIndicator()),
    this.fit = BoxFit.fill,
    @required this.filename,
    this.circleShape = false,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => new _PhotoFilterSelectorState();
}

class _PhotoFilterSelectorState extends State<PhotoFilterSelector> {
  String filename;
  Map<String, List<int>> cachedFilters = {};
  Filter _filter;
  imageLib.Image image;
  bool loading;
  List<String> filterImages = ["exampleimages/No Filter.jpg",
  "exampleimages/AddictiveBlue.jpg",
  "exampleimages/AddictiveRed.jpg",
  "exampleimages/Aden.jpg",
  "exampleimages/Amaro.jpg",
  "exampleimages/Ashby.jpg",
  "exampleimages/Brannan.jpg",
  "exampleimages/Brooklyn.jpg",
  "exampleimages/Charmes.jpg",
  "exampleimages/Clarendon.jpg",
  "exampleimages/Crema.jpg",
  "exampleimages/Dogpatch.jpg",
  "exampleimages/Earlybird.jpg",
  "exampleimages/Gingham.jpg",
  "exampleimages/Ginza.jpg",
  "exampleimages/Hefe.jpg",
  "exampleimages/Helena.jpg",
  "exampleimages/Hudson.jpg",
  "exampleimages/Inkwell.jpg",
  "exampleimages/Juno.jpg",
  "exampleimages/Kelvin.jpg",
  "exampleimages/Lark.jpg",
  "exampleimages/Lo-Fi.jpg",
  "exampleimages/Ludwig.jpg",
  "exampleimages/Maven.jpg",
  "exampleimages/Mayfair.jpg",
  "exampleimages/Moon.jpg",
  "exampleimages/Nashville.jpg",
  "exampleimages/No Filter.jpg",
  "exampleimages/Perpetua.jpg",
  "exampleimages/Reyes.jpg",
  "exampleimages/Rise.jpg",
  "exampleimages/screenshot.gif",
  "exampleimages/Sierra.jpg",
  "exampleimages/Skyline.jpg",
  "exampleimages/Slumber.jpg",
  "exampleimages/Stinson.jpg",
  "exampleimages/Sutro.jpg",
  "exampleimages/Toaster.jpg",
  "exampleimages/Valencia.jpg",
  "exampleimages/Vesper.jpg",
  "exampleimages/Walden.jpg",
  "exampleimages/Willow.jpg",
  "exampleimages/X-Pro II.jpg"];

  @override
  void initState() {
    super.initState();
    loading = false;
    _filter = widget.filters[0];
    filename = widget.filename;
    image = widget.image;
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int height = image.height;
    int width = image.width;
    double ratio = height/width;
    double previewwidth = MediaQuery.of(context).size.width;
    double previewHeight = previewwidth * ratio;
    return Scaffold(
      appBar: AppBar(
        title: widget.title,
        actions: <Widget>[
          loading
              ? Container()
              : IconButton(
            icon: Icon(Icons.check),
            onPressed: () async {
              setState(() {
                loading = true;
              });
              var imageFile = await saveFilteredImage();

              Navigator.pop(context, {'image_filtered':imageFile} );
            },
          )
        ],
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: loading
            ? widget.loader
            : Column(
          children: [
            Expanded(
                flex: 8,
                child: Row(
                  children: <Widget>[
                    Container(
                      width: previewwidth,
                      height: previewHeight,
                      padding: EdgeInsets.all(12.0),
                      child: _buildFilteredImage(
                          _filter,
                          image,
                          filename,
                          previewwidth,
                          previewHeight
                      ),
                    ),
                  ],
                )
            ),
            Expanded(
              flex:2,
              child: Container(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.filters.length,
                  itemBuilder: (BuildContext context, int index) {
                    return InkWell(
                      child: Container(
                        padding: EdgeInsets.all(5.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            _buildFilterThumbnail(
                                filterImages[index], widget.filters[index], image, filename),
                            SizedBox(
                              height: 5.0,
                            ),
                            Text(
                              widget.filters[index].name,
                            )
                          ],
                        ),
                      ),
                      onTap: () => setState(() {
                        _filter = widget.filters[index];
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildFilterThumbnail(String filterImage, Filter filter, imageLib.Image image, String filename) {
    return CircleAvatar(
      radius: 50.0,
      backgroundImage: AssetImage(
        filterImage
      ),
      backgroundColor: Colors.white,
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/filtered_${_filter?.name ?? "_"}_$filename');
  }

  Future<File> saveFilteredImage() async {
    var imageFile = await _localFile;
    await imageFile.writeAsBytes(cachedFilters[_filter?.name ?? "_"]);
    return imageFile;
  }

  Widget _buildFilteredImage(
      Filter filter, imageLib.Image image, String filename, double width, double height) {
    if (cachedFilters[filter?.name ?? "_"] == null) {
      return FutureBuilder<List<int>>(
        future: compute(applyFilter, <String, dynamic>{
          "filter": filter,
          "image": image,
          "filename": filename,
        }),
        builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
              return widget.loader;
            case ConnectionState.active:
            case ConnectionState.waiting:
              return widget.loader;
            case ConnectionState.done:
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              cachedFilters[filter?.name ?? "_"] = snapshot.data;
              return widget.circleShape
                  ? SizedBox(
                height: MediaQuery.of(context).size.width / 3,
                width: MediaQuery.of(context).size.width / 3,
                child: Center(
                  child: CircleAvatar(
                    radius: MediaQuery.of(context).size.width / 3,
                    backgroundImage: MemoryImage(
                      snapshot.data,
                    ),
                  ),
                ),
              )
                  : Image.memory(
                  snapshot.data,
                  fit: BoxFit.cover,
                  height: height,
                  width:width
              );
          }
          return null; // unreachable
        },
      );
    } else {
      return widget.circleShape
          ? SizedBox(
        height: MediaQuery.of(context).size.width / 3,
        width: MediaQuery.of(context).size.width / 3,
        child: Center(
          child: CircleAvatar(
            radius: MediaQuery.of(context).size.width / 3,
            backgroundImage: MemoryImage(
              cachedFilters[filter?.name ?? "_"],
            ),
          ),
        ),
      )
          : Image.memory(
          cachedFilters[filter?.name ?? "_"],
          fit: widget.fit,
          height: height,
          width:width
      );
    }
  }
}

///The global applyfilter function
List<int> applyFilter(Map<String, dynamic> params) {
  Filter filter = params["filter"];
  imageLib.Image image = params["image"];
  String filename = params["filename"];
  List<int> _bytes = image.getBytes();
  if (filter != null) {
    filter.apply(_bytes);
  }
  imageLib.Image _image =
      imageLib.Image.fromBytes(image.width, image.height, _bytes);
  _bytes = imageLib.encodeNamedImage(_image, filename);

  return _bytes;
}

///The global buildThumbnail function
List<int> buildThumbnail(Map<String, dynamic> params) {
  int width = params["width"];
  params["image"] = imageLib.copyResize(params["image"], width: width);
  return applyFilter(params);
}
