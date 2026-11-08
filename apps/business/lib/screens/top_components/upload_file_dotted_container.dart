import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mawaroute_business/theme/constants.dart';

class UploadFileDottedContainer extends StatefulWidget {
  final Function(PlatformFile)? callback;
  final PlatformFile file;
  final double height;
  final double width;
  final bool absorb;
  const UploadFileDottedContainer({
    super.key,
    this.callback,
    required this.file,
    this.height = 300,
    this.width = 400,
    this.absorb = false,
  });

  @override
  State<UploadFileDottedContainer> createState() =>
      _UploadFileDottedContainerState();
}

class _UploadFileDottedContainerState extends State<UploadFileDottedContainer> {
  bool _isHover = false;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding / 1.35),
      child: AbsorbPointer(
        absorbing: widget.absorb,
        child: DottedBorder(
          options: RoundedRectDottedBorderOptions(
            color: CupertinoColors.lightBackgroundGray,
            radius: const Radius.circular(12),
            strokeWidth: 1.2,
          ),
          child: InkWell(
            onTap: () async {
              FilePickerResult? result = await FilePicker.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['jpg', 'png'],
              );
              if (result != null) {
                widget.callback!(result.files.single);
              }
            },
            hoverColor: Colors.transparent,
            onHover: (bool bool) {
              setState(() {
                _isHover = bool;
              });
            },
            child: widget.file.size <= 0
                ? Container(
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _isHover ? kPrimaryColor : kPrimaryLightColor,
                    ),
                    child: const Center(
                      child: Icon(
                        CupertinoIcons.photo,
                        color: Colors.white,
                      ),
                    ),
                  )
                : Container(
                    height: widget.height,
                    width: widget.width,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: widget.file.name.contains('https://')
                          ? DecorationImage(
                              image: NetworkImage(widget.file.name),
                              fit: BoxFit.cover)
                          : DecorationImage(
                              image: MemoryImage(
                                widget.file.bytes!,
                              ),
                              fit: BoxFit.cover),
                    ),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            if (!widget.absorb)
                              IconButton(
                                onPressed: () {
                                  widget.callback!(
                                      PlatformFile(name: '', size: 0));
                                },
                                splashRadius: 9,
                                icon: const Icon(
                                  CupertinoIcons.clear_circled_solid,
                                  color: Colors.white,
                                ),
                              ),
                          ],
                        )
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
