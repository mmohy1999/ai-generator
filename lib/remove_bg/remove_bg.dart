import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class RemoveBg extends StatefulWidget {
  const RemoveBg({super.key});

  @override
  State<RemoveBg> createState() => _RemoveBgState();
}

class _RemoveBgState extends State<RemoveBg> with TickerProviderStateMixin{
   File? imageBefore;
   File? imageAfter;
  final picker = ImagePicker();

   bool showSpinner = false;
   late final AnimationController animationController;
   bool isSent = false;

@override
  void initState() {
  animationController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );
    super.initState();
  }

   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 10.0),
          child: Text(
            'Image Generator',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: 0.6),
          ),
        ),
        elevation: 2,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: GestureDetector(
            child: const Icon(Icons.arrow_back),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      bottomNavigationBar: Container(
        width: double.infinity,
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 10).copyWith(bottom: 10),
        child: ElevatedButton(
          onPressed: () {
            if(imageBefore!=null) {
              setState(() {
                showSpinner = true;
              });
              isSent = false;
              removeImageBackground();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            elevation: 2,
            shadowColor: Colors.grey,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ).copyWith(
            overlayColor: WidgetStateProperty.resolveWith<Color?>(
                  (Set<WidgetState> states) {
                if (states.contains(WidgetState.pressed)) {
                  return Colors.grey.shade300;
                }
                return null;
              },
            ),
          ),
          child: const Text(
            'Generate',
            style: TextStyle(
                fontSize: 23, fontWeight: FontWeight.w900, color: Colors.black),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraint) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraint.maxHeight),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    Visibility(
                      visible: showSpinner,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: SpinKitCircle(
                          color: Colors.white,
                          size: 50.0,
                          controller: animationController,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: showSpinner == false,
                      child: Container(
                        margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        height: MediaQuery.of(context).size.height * 0.42,
                        width: 396.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: isSent
                              ? Image.file(imageAfter!)
                              : Image.asset(
                            'assets/images/default_image.jpg',
                            fit: BoxFit.fitWidth,
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        const Expanded(
                          child: SizedBox(),
                        ),
                        button(
                          text: 'Download',
                          icon: Icons.download,
                          onPressed: () async {
                            if(imageAfter!=null) {
                              saveFile();
                            }
                          },
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Expanded(child: GestureDetector(onTap: () {
                      getImage();
                    },child: bottomUploadImage())),
                    const SizedBox(
                      height: 3,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }


   Future<void> requestStoragePermission() async {
     var status = await Permission.storage.status;
     if (!status.isGranted) {
       await Permission.storage.request();
     }
   }

   Future<void> saveFile() async {
     try {
       await requestStoragePermission();

       Directory downloadsDirectory = Directory('/storage/emulated/0/Download');

       String downloadsPath = downloadsDirectory.path;

       String fileName = imageAfter!.path.split('/').last;
       String newPath = '$downloadsPath/$fileName';

       await imageAfter!.copy(newPath);

       print('File saved to: $newPath');
     } catch (e) {
       print('Error saving file: $e');
     }
   }




   Widget bottomUploadImage() {
     return Padding(
       padding: const EdgeInsets.symmetric(horizontal: 10.0).copyWith(bottom: 5),
       child: Container(
         decoration: BoxDecoration(
           color: Colors.grey.shade900,
           borderRadius: BorderRadius.circular(20).copyWith(
             bottomLeft: const Radius.circular(30),
             bottomRight: const Radius.circular(30),
           ),
         ),
         child:  Padding(
           padding: const EdgeInsets.symmetric(horizontal: 15.0),
           child: Center(
             child: Container(
               decoration:imageBefore!=null? BoxDecoration(
                 image: DecorationImage(
                   image: FileImage(imageBefore!),
                   fit: BoxFit.cover,
                 ),
               ):null,
               child:imageBefore!=null? null:const Column(
                 mainAxisSize: MainAxisSize.min,
                 children: [
                   Icon(Icons.cloud_download,size:52,),
                   SizedBox(height: 8,),
                   Text('Upload Your Image',style: TextStyle(fontSize:24),),
                 ],
               ),
             )
           ),
           ),
         ),
       );
   }

   button({required String text,required IconData icon,required VoidCallback onPressed}){
    return Expanded(
       child: SizedBox(
         width: double.infinity,
         child: ElevatedButton(
           onPressed: onPressed,
           style: ElevatedButton.styleFrom(
             backgroundColor: Colors.grey.shade900,
             elevation: 1,
             shadowColor: Colors.grey,
             shape:
             RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
           ).copyWith(
             overlayColor: WidgetStateProperty.resolveWith<Color?>(
                   (Set<WidgetState> states) {
                 if (states.contains(WidgetState.pressed)) {
                   return Colors.grey.shade800;
                 }
                 return null;
               },
             ),
           ),
           child: Row(
             crossAxisAlignment: CrossAxisAlignment.center,
             children: [
               Icon(icon),
               const SizedBox(width: 8,),
               Text(
                 text,
                 style: const TextStyle(
                   fontSize: 16,
                   fontWeight: FontWeight.w900,
                   color: Colors.white,
                 ),
               )
             ],
           ),
         ),
       ),
     );

   }





  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if(pickedFile!=null){
      setState(() {
        imageBefore=File(pickedFile.path);
      });
    }
  }

    removeImageBackground() async {
     String apiKey = 'YOUR_API_KEY';

     var request = http.MultipartRequest(
       'POST',
       Uri.parse('https://api.remove.bg/v1.0/removebg'),
     );
     request.headers['X-Api-Key'] = apiKey;
     request.files.add(await http.MultipartFile.fromPath('image_file', imageBefore!.path));

     request.fields['size'] = 'auto'; // Optional, you can set image size

     var response = await request.send();

     if (response.statusCode == 200) {
       var bytes = await response.stream.toBytes();
       File outputImage = File('${Directory.systemTemp.path}/no-bg.png');
       print('path: ${outputImage.path}');
       await outputImage.writeAsBytes(bytes);
       imageAfter =outputImage;

       showSpinner = false;
       isSent = true;
       setState(() {

       });
     } else {
       setState(() {
         showSpinner = false;
         isSent = false;
       });
     }
   }

}
