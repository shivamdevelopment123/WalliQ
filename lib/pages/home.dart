import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List wallpaperImage = [];
  int activeIndex=0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WalliQ', style: TextStyle(fontFamily: 'Poppins'),),
        actions: [
          IconButton(onPressed: (){}, icon: Icon(Icons.search)),
          IconButton(onPressed: (){}, icon: Icon(Icons.more_vert)),
        ],
      ),
      body: Container(
        child: Column(
          children: [
            CarouselSlider.builder(itemCount: wallpaperImage.length,
                itemBuilder: (context, index, realIndex){
              final res = wallpaperImage[index];
              return buildImage(res, index);
                },
                options: CarouselOptions(
                  height: MediaQuery.of(context).size.height/1.5,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  onPageChanged: (index, reason) => setState(() => activeIndex = index)
                ),
            ),
            SizedBox(height: 20,),
            buildIndicator(),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator() => AnimatedSmoothIndicator(activeIndex: activeIndex, count: 3,
      effect: WormEffect(activeDotColor: Colors.blueAccent,
          dotColor: Colors.grey,));

  Widget buildImage(String urlImage, int index) => Container(
    height: MediaQuery.of(context).size.height/1.5,
    width: MediaQuery.of(context).size.width,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
        child: Image.asset(urlImage, fit: BoxFit.cover,)),
  );
}
