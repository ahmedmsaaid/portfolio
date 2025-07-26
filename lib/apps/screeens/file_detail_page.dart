import 'package:awesome_portfolio/apps/data/apps_cubit/apps_cubit.dart';
import 'package:awesome_portfolio/apps/screeens/apps_screen.dart';
import 'package:awesome_portfolio/consts/dialog.dart';
import 'package:awesome_portfolio/providers/current_state.dart';
import 'package:awesome_portfolio/screen/homescreen/phone_home_page.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class FileDetailPage extends StatelessWidget {
  final String file;

  FileDetailPage({required this.file});

  @override
  Widget build(BuildContext context) {
    CurrentState currentState =
        Provider.of<CurrentState>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.black12,
      body: BlocProvider(
        create: (_) => AppsCubit()
          ..loadFileImages(
              "https://api.github.com/repos/ahmedmsaaid/assets/contents/$file"),
        child: BlocBuilder<AppsCubit, AppsState>(
          builder: (context, state) {
            if (state is FileImagesLoading) {
              return Center(child: CircularProgressIndicator());
            } else if (state is FileImagesLoaded) {
              final images = state.images;
              CurrentState instance =
                  Provider.of<CurrentState>(context, listen: false);

              return Stack(
                children: [
                  // Carousel Slider
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 50), // Space for the back button
                      Center(
                        child: CarouselSlider(
                          options: CarouselOptions(
                            height: MediaQuery.of(context).size.height * 0.8,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            enableInfiniteScroll: true,
                            viewportFraction: 0.8,
                            aspectRatio: 16 / 9,
                          ),
                          items: images.map((imageUrl) {
                            return Container(
                              margin: EdgeInsets.all(8.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 10,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(15),
                                child: Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  // Back Button
                  Positioned(
                    top: 20,
                    left: 10,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          instance.changePhoneScreen(
                            PhoneHomeScreen(),
                            true,
                          );
                          Alerts.showMassage(
                              context,
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(100), // نصف الدائرة
                                ),
                                child: Center(
                                  child: Scaffold(
                                    backgroundColor: Colors.transparent,
                                    body: BlocProvider(
                                      create: (_) => AppsCubit()
                                        ..loadFiles(
                                            "https://api.github.com/repos/ahmedmsaaid/assets"),
                                      child: BlocBuilder<AppsCubit, AppsState>(
                                        builder: (context, state) {
                                          if (state is FileGridLoading) {
                                            return Center(
                                                child: Lottie.asset(
                                                    "assets/lottie/loading.json"));
                                          } else if (state is FileGridLoaded) {
                                            // تصفية الملفات لإزالة "Zicons"
                                            final files = state.files
                                                .where(
                                                    (file) => file != "Zicons")
                                                .toList();

                                            return GridView.builder(
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 1,
                                                mainAxisSpacing: 1,
                                              ),
                                              itemCount: files.length,
                                              itemBuilder: (context, index) {
                                                final file = files[index];

                                                return GestureDetector(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    currentState
                                                        .changePhoneScreen(
                                                      FileDetailPage(
                                                          file: file),
                                                      false,
                                                      titlee: file,
                                                    );
                                                  },
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      FutureBuilder<String>(
                                                        future:
                                                            checkImageUrl(file),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                                  .connectionState ==
                                                              ConnectionState
                                                                  .waiting) {
                                                            return Center(
                                                                child:
                                                                    Container());
                                                          } else if (snapshot
                                                              .hasError) {
                                                            return Image.network(
                                                                "https://example.com/default_image.jpeg"); // صورة افتراضية
                                                          } else {
                                                            return AppWidget(
                                                              imageUrl: snapshot
                                                                      .data ??
                                                                  '',
                                                              appName: file,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            );
                                          } else if (state is FileGridError) {
                                            return Center(
                                                child: Text(
                                                    'Error: ${state.message}'));
                                          }
                                          return Center(
                                              child: Text('No files found.'));
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ));
                        },
                        icon: Icon(
                          Icons.arrow_back_sharp,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            } else if (state is FileImagesError) {
              return Center(child: Text('Error: ${state.message}'));
            }
            return Center(child: Text('No images found.'));
          },
        ),
      ),
    );
  }
}

Future<String> checkImageUrl(String file) async {
  String uri =
      "https://raw.githubusercontent.com/ahmedmsaaid/assets/main/Zicons/$file.png"; // تعديل ليتناسب مع اسم الصورة
  try {
    final response = await Dio().head(uri);

    // تحقق مما إذا كان الرابط يعمل
    if (response.statusCode == 200) {
      return uri; // الرابط شغال
    } else {
      throw Exception('رابط الصورة غير شغال');
    }
  } catch (e) {
    final link = uri.replaceAll("png", "jpeg");
    // في حالة وجود خطأ، نعيد رابط للصورة الافتراضية
    return link; // تغيير هذا إلى رابط صورة افتراضية أو تغييره إلى jpeg
  }
}
