import 'package:carousel_slider/carousel_slider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:health_care/providers/theme_provider.dart';
import 'package:health_care/src/commons/page_scaffold_wrapper.dart';
import 'package:typewritertext/typewritertext.dart';
import 'package:health_care/theme_config.dart';
import 'package:provider/provider.dart';

class EyeCareHome extends StatefulWidget {
  static const String routeName = '/eyecarehome';
  const EyeCareHome({super.key});

  @override
  State<EyeCareHome> createState() => _EyeCareHomeState();
}

class _EyeCareHomeState extends State<EyeCareHome> {
  @override
  Widget build(BuildContext context) {
    return PageScaffoldWrapper(
      title: 'apptitle',
      children: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 3,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              RotatedBox(
                quarterTurns: 0,
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      alignment: Alignment.topCenter,
                      image: NetworkImage("https://health-care.duckdns.org/assets/images/bg/ban-bg-01.webp", scale: 1),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              const EyeCareBanner(),
              Padding(
                padding: const EdgeInsets.only(top: 380.0),
                child: EyeCareCircleAvatar(
                  imagesList: const [
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-13.webp',
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-14.webp',
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-15.webp',
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-16.webp',
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-17.webp',
                    'https://health-care.duckdns.org/assets/images/doctors/doctor-18.webp'
                  ],
                  title: context.tr('eyeClinicExperience'),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 600.0),
                child: EyeCareSpecialists(),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 1200.0),
                child: EyeCareWhoWeAre(),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class EyeCareBanner extends StatefulWidget {
  const EyeCareBanner({super.key});

  @override
  State<EyeCareBanner> createState() => _EyeCareBannerState();
}

class _EyeCareBannerState extends State<EyeCareBanner> {
  @override
  Widget build(BuildContext context) {
    final firstValueController = TypeWriterController(
      text: 'firstParagraphEyeBaner',
      duration: const Duration(milliseconds: 90),
    );
    final secondValueController = TypeWriterController(
      text: 'secondParagraphEyeBaner',
      duration: const Duration(milliseconds: 50),
    );
    return Card(
      elevation: 12,
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: 350,
        alignment: Alignment.topCenter,
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(
              'https://health-care.duckdns.org/assets/images/banner-11.webp',
            ),
            fit: BoxFit.cover,
            opacity: 0.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            TypeWriter(
              controller: firstValueController, // streamController
              builder: (context, value) {
                return Text(
                  context.tr(value.text),
                  maxLines: 2,
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                  // : 2.0,
                );
              },
            ),
            TypeWriter(
              controller: secondValueController, // streamController
              builder: (context, value) {
                return Text(
                  style: const TextStyle(fontSize: 50),
                  context.tr(value.text),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  // : 2.0,
                );
              },
            ),
            ElevatedButton(
              onPressed: () => {
                context.push(
                  Uri(path: '/doctors/search', queryParameters: {}).toString(),
                )
              },
              child: Text(
                context.tr('makeAppointment'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EyeCareCircleAvatar extends StatefulWidget {
  final List<String> imagesList;
  final String title;
  const EyeCareCircleAvatar({
    super.key,
    required this.imagesList,
    required this.title,
  });

  @override
  State<EyeCareCircleAvatar> createState() => _EyeCareCircleAvatarState();
}

class _EyeCareCircleAvatarState extends State<EyeCareCircleAvatar> with TickerProviderStateMixin {
  late final List<AnimationController> _controller = [];
  late final List<Animation<Offset>> _offsetAnimation = [];

  @override
  void initState() {
    super.initState();
    // Initialize the AnimationController
    for (int i = 0; i < widget.imagesList.length; i++) {
      _controller.add(AnimationController(vsync: this, duration: const Duration(seconds: 2)));

      // Define the animation starting from outside the screen to the center
      _offsetAnimation.add(Tween<Offset>(begin: Offset(3 + i.toDouble(), 0), end: Offset.zero).animate(
        CurvedAnimation(parent: _controller[i], curve: Curves.easeInOut),
      ));
      Future.delayed(Duration(milliseconds: i * 500), () {
        _controller[i].forward();
      });
    }
  }

  @override
  void dispose() {
   for (var controller in _controller) {
    controller.dispose();
  }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    String primaryColor = primaryColorCodeReturn(homeThemeName);
    return Center(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.string(
                  '<svg width="25" height="20" viewBox="0 0 25 20" fill="none" xmlns="http://www.w3.org/2000/svg"><path d="M8.10018 2.29104H1.5M4.80009 17.6915H1.5M2.60003 9.99125H1.5M16.2294 2.52205L17.7804 5.62414C17.9894 6.05315 18.5505 6.46016 19.0235 6.54816L21.8286 7.01017C23.6216 7.30718 24.0396 8.60522 22.7526 9.90325L20.5635 12.0923C20.2005 12.4553 19.9915 13.1703 20.1125 13.6874L20.7395 16.3934C21.2345 18.5275 20.0905 19.3635 18.2095 18.2415L15.5804 16.6794C15.1074 16.3934 14.3154 16.3934 13.8423 16.6794L11.2133 18.2415C9.33221 19.3525 8.18818 18.5275 8.6832 16.3934L9.31021 13.6874C9.43122 13.1813 9.22221 12.4663 8.8592 12.0923L6.67014 9.90325C5.38311 8.61622 5.80112 7.31818 7.59417 7.01017L10.3992 6.54816C10.8723 6.47116 11.4333 6.05315 11.6423 5.62414L13.1933 2.52205C14.0183 0.839004 15.3824 0.839004 16.2294 2.52205Z" stroke="#$primaryColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round" /></svg>'),
              Text(
                widget.title,
                style: TextStyle(
                  fontSize: 24,
                  color: Theme.of(context).primaryColorLight,
                ),
              )
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < widget.imagesList.length; i++)
                Align(
                  widthFactor: 0.5,
                  child: SlideTransition(
                    position: _offsetAnimation[i],
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Theme.of(context).primaryColorLight,
                      child: CircleAvatar(
                        radius: 48,
                        backgroundImage: NetworkImage(widget.imagesList[i]),
                      ),
                    ),
                  ),
                )
            ],
          )
        ],
      ),
    );
  }
}

class EyeCareSpecialists extends StatefulWidget {
  const EyeCareSpecialists({super.key});

  @override
  State<EyeCareSpecialists> createState() => _EyeCareSpecialistsState();
}

List<Map<String, String>> eyeSpecialitiesImages = [
  {
    "image": 'https://health-care.duckdns.org/assets/images/clients/clinic-011.webp',
    "title": 'Keratoconus',
  },
  {
    "image": 'https://health-care.duckdns.org/assets/images/clients/clinic-012.webp',
    "title": 'Cataract',
  },
  {
    "image": 'https://health-care.duckdns.org/assets/images/clients/clinic-013.webp',
    "title": 'Corneal',
  },
  {
    "image": 'https://health-care.duckdns.org/assets/images/clients/clinic-014.webp',
    "title": 'Keratoconus',
  },
  {
    "image": 'https://health-care.duckdns.org/assets/images/clients/clinic-015.webp',
    "title": 'Glaucoma',
  },
];

class _EyeCareSpecialistsState extends State<EyeCareSpecialists> {
  CarouselSliderController buttonCarouselController = CarouselSliderController();
  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    String primaryColor = primaryColorCodeReturn(homeThemeName);
    var brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Center(
          child: SvgPicture.string(
            eyeIconSvg(brightness == Brightness.dark ? '#fff' : '#000', "#$primaryColor"),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: context.tr('our').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).primaryColorLight, fontSize: 34, fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(
                    text: context.tr('specialties').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 34, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.tr('eyeGreatPlace'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        CarouselSlider(
          options: CarouselOptions(
            autoPlay: true,
            enlargeCenterPage: true,
            viewportFraction: 0.9,
            aspectRatio: 2.0,
            initialPage: 2,
            height: 270,
          ),
          items: eyeSpecialitiesImages.map(
            (i) {
              return SizedBox(
                height: 270,
                child: Stack(
                  children: [
                    Image.network(
                      i['image']!,
                      height: 200,
                    ),
                    Positioned(
                      top: 165,
                      left: 67,
                      child: RotationTransition(
                        turns: const AlwaysStoppedAnimation(0.125),
                        child: Container(
                          alignment: Alignment.center,
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(100),
                                topRight: Radius.circular(0),
                                bottomRight: Radius.circular(100),
                                bottomLeft: Radius.circular(0)),
                            color: Theme.of(context).primaryColor,
                          ),
                          child: const RotationTransition(
                            turns: AlwaysStoppedAnimation(-0.120),
                            child: FaIcon(
                              FontAwesomeIcons.chevronCircleRight,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned.fill(
                      // bottom: -6,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          context.tr(i['title']!),
                          style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ).toList(),
          carouselController: buttonCarouselController,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              onPressed: () => buttonCarouselController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
              icon: FaIcon(
                FontAwesomeIcons.chevronCircleLeft,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
            IconButton(
              onPressed: () => buttonCarouselController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.linear),
              icon: FaIcon(
                FontAwesomeIcons.chevronCircleRight,
                color: Theme.of(context).primaryColorLight,
              ),
            ),
          ],
        ),
        Center(
          child: Opacity(
            opacity: 0.3,
            child: SvgPicture.string(
              eyeSvg(
                brightness == Brightness.dark ? '#fff' : '#000',
                "#$primaryColor",
                brightness == Brightness.dark ? '#000' : '#fff',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

String eyeSvg(String color, String fill, String paper) {
  return '''<svg width="132" height="79" viewBox="0 0 132 79" fill="none" xmlns="http://www.w3.org/2000/svg">
      <path d="M130.661 58.4501C130.875 58.4501 131.086 58.3426 131.206 58.1448C131.39 57.8452 131.295 57.4524 130.995 57.2689L98.5109 37.4379L131.659 19.9119C131.972 19.747 132.091 19.3614 131.926 19.0504C131.761 18.7393 131.375 18.6203 131.064 18.7852L96.9254 36.8344C96.7233 36.9419 96.5943 37.1497 96.5872 37.3791C96.58 37.6085 96.696 37.8235 96.8924 37.9425L130.332 58.3584C130.434 58.42 130.548 58.4501 130.661 58.4501Z" fill="$color" />
      <path d="M112.946 57.1148C113.154 57.1148 113.356 57.0145 113.479 56.8281C113.673 56.5343 113.591 56.1386 113.297 55.9451L97.1056 45.2727C96.8117 45.0806 96.4175 45.1594 96.2225 45.4547C96.029 45.7486 96.1093 46.1442 96.4046 46.3378L112.596 57.0102C112.703 57.0819 112.825 57.1148 112.946 57.1148Z" fill="$color" />
      <path d="M99.5057 56.6802C99.6964 56.6802 99.8842 56.5956 100.009 56.4351C100.225 56.157 100.177 55.757 99.9 55.5406L95.5851 52.1747C95.307 51.9568 94.9057 52.007 94.6906 52.2851C94.4742 52.5632 94.5229 52.9631 94.801 53.181L99.1144 56.5469C99.2305 56.6372 99.3681 56.6802 99.5057 56.6802Z" fill="$color" />
      <path d="M50.7565 71.1215C59.1511 69.3669 70.1131 65.9035 74.544 53.7962C81.1238 52.1032 86.5467 39.9213 85.5031 31.7088C84.2631 21.9381 79.5527 17.3594 74.544 15.0286C70.7481 7.95425 60.51 2.51842 52.2244 1.16376C40.011 -0.833107 26.7468 2.95134 19.0862 13.2912C10.7418 24.5571 11.156 37.3783 17.7315 49.9057C18.5371 51.4381 18.474 52.334 16.8771 52.8558C3.96844 57.066 2.90338 63.9052 0.637016 71.1458C3.31049 74.5533 5.0866 76.748 7.6067 78.1772C6.25777 70.7287 10.5827 66.6145 16.2249 63.5067C18.0268 62.5147 25.1184 60.601 26.4544 62.1865C32.994 69.956 44.819 72.3629 50.7565 71.1215Z" fill="$color" />
      <path d="M7.60533 78.8162C7.73578 78.8162 7.86479 78.7761 7.97517 78.6987C8.17729 78.5553 8.27763 78.3088 8.23318 78.0651C7.14516 72.0573 9.62656 67.8714 16.5317 64.0655C18.4813 62.9904 25.0381 61.4967 25.9656 62.599C32.6729 70.5621 44.7473 73.0263 50.887 71.7448C59.7675 69.8898 70.5116 66.2301 75.0286 54.322C81.885 52.2133 87.1632 39.7132 86.1353 31.6282C85.0645 23.1935 81.422 17.6029 75.0028 14.5409C70.9273 7.18275 60.3165 1.84153 52.3262 0.534175C38.7997 -1.67485 25.8681 3.06717 18.5744 12.9125C10.5411 23.7569 10.0537 36.6512 17.1668 50.2021C17.5395 50.9131 17.6728 51.4091 17.5624 51.68C17.4735 51.8951 17.1768 52.0872 16.6793 52.2491C4.4702 56.23 2.56369 62.5589 0.546761 69.2591C0.377602 69.821 0.206985 70.3872 0.0292282 70.9549C-0.033844 71.1556 0.00634766 71.3735 0.135361 71.5383C2.88052 75.0375 4.69524 77.258 7.29131 78.7316C7.38879 78.789 7.49782 78.8162 7.60533 78.8162ZM24.2253 60.9548C21.2709 60.9548 17.0808 62.308 15.9153 62.9502C11.2393 65.5262 6.08723 69.4182 6.78534 76.8896C4.98916 75.5751 3.44955 73.6972 1.34374 71.018C1.48853 70.5535 1.62621 70.0905 1.76669 69.6289C3.76785 62.9803 5.49949 57.2377 17.0736 53.4633C17.958 53.1752 18.5042 52.7494 18.7436 52.1617C19.0862 51.3159 18.6848 50.3541 18.2949 49.6115C11.4256 36.5236 11.8757 24.0966 19.598 13.6722C26.6078 4.21254 39.0706 -0.34026 52.1212 1.79422C59.8793 3.06287 70.1776 8.23781 73.9836 15.3308C74.0481 15.4512 74.1513 15.5487 74.276 15.6074C80.3841 18.4486 83.8489 23.7426 84.8725 31.7902C85.8343 39.3591 80.7282 51.5482 74.3864 53.1795C74.1828 53.2325 74.0194 53.3816 73.9463 53.578C69.7146 65.1406 59.2629 68.6943 50.6275 70.4976C44.8018 71.7161 33.328 69.3623 26.9418 61.7776C26.4386 61.1813 25.4366 60.9548 24.2253 60.9548Z" fill="$color" />
      <path d="M73.3225 46.786C80.3394 44.6816 82.008 30.9157 77.4552 23.516C76.8173 22.4767 75.9243 21.393 74.5467 21.1436C73.2293 20.9056 71.8589 21.5492 71.079 22.4566C70.2992 23.3626 69.9981 24.4865 69.7788 25.5831C68.7166 30.857 69.0993 36.2469 69.4864 41.5838C69.5581 42.5601 69.6355 43.5621 70.1272 44.4508C70.616 45.3396 71.2396 47.411 73.3225 46.786Z" fill="$fill" />
      <path d="M72.5855 47.5409C72.8651 47.5409 73.1704 47.4965 73.5044 47.3961C76.0546 46.6321 78.0745 44.4675 79.3402 41.1375C81.4905 35.4924 80.9257 27.9407 77.997 23.1814C77.3835 22.1866 76.3715 20.8262 74.6584 20.5166C73.0114 20.2155 71.4302 21.067 70.5944 22.0404C69.7286 23.0481 69.3888 24.2781 69.1509 25.4564C68.0657 30.8421 68.4642 36.3267 68.8484 41.6292C68.9201 42.6154 69.0004 43.7336 69.5666 44.7585C69.6297 44.8717 69.6942 45.0065 69.7645 45.1513C70.1601 45.9684 70.9212 47.5409 72.5855 47.5409ZM73.9818 21.7307C74.1308 21.7307 74.2813 21.7437 74.4304 21.7709C75.3536 21.9372 76.1407 22.598 76.9104 23.8509C79.6484 28.3005 80.1688 35.3805 78.1475 40.6845C77.3663 42.7387 75.8611 45.3591 73.1374 46.1762C71.9519 46.5303 71.4675 45.7462 70.9113 44.5965C70.8295 44.4288 70.755 44.274 70.6818 44.1435C70.2518 43.3637 70.1845 42.4362 70.12 41.5374C69.7401 36.3195 69.3487 30.9238 70.3995 25.7087C70.6346 24.5433 70.9212 23.6144 71.5591 22.8718C72.0652 22.2841 72.9955 21.7307 73.9818 21.7307Z" fill="$paper" />
      <path d="M4.3151 71.3365C4.5803 71.3365 4.92289 70.8921 6.23454 69.0816C7.48885 67.3514 9.2048 64.9832 10.8806 63.3089C15.6254 58.564 26.1129 57.7225 27.4934 58.8378C34.291 64.3353 42.2671 67.3298 49.4131 67.0761C57.1626 66.7909 69.9279 60.1122 71.5062 50.6955C71.5262 50.5794 71.4474 50.4705 71.3313 50.4504C71.2151 50.4317 71.1063 50.5092 71.0862 50.6253C69.5423 59.8369 57.0106 66.3723 49.3973 66.6518C42.3746 66.9098 34.4803 63.9411 27.7601 58.5081C26.2778 57.3097 15.5795 58.0078 10.5795 63.0078C8.88079 64.7065 7.15199 67.0919 5.89052 68.8322C5.39165 69.5188 4.88277 70.2227 4.55737 70.614C4.95589 69.0959 6.67757 64.1862 9.26647 61.5987C12.6495 58.2142 16.821 56.9069 19.579 56.041C21.3666 55.4805 22.4446 55.1437 22.6367 54.5015C23.1814 52.6881 22.6969 50.7715 22.1536 48.9638C21.5974 47.1118 21.09 45.6625 20.6413 44.3824C19.4959 41.1111 18.739 38.9494 18.5612 33.9909C18.2602 25.5705 20.8936 19.0481 27.0992 12.8439C34.175 5.76816 41.6004 5.19333 49.8775 5.19333C57.5295 5.19333 68.0342 12.0397 70.6933 18.7585C70.7363 18.8675 70.8611 18.922 70.9686 18.8775C71.0775 18.8345 71.1306 18.7112 71.089 18.6023C68.3768 11.7502 57.6743 4.76758 49.8775 4.76758C41.5044 4.76758 33.9886 5.35245 26.7982 12.5429C20.5882 18.7528 17.8359 25.572 18.137 34.0053C18.3161 39.0282 19.0816 41.2129 20.2399 44.5214C20.6871 45.7972 21.1932 47.2422 21.7465 49.0843C22.2712 50.8303 22.7399 52.678 22.231 54.3782C22.102 54.8025 20.8763 55.1881 19.4529 55.6339C16.6532 56.5112 12.4244 57.8386 8.9654 61.2962C5.88767 64.374 4.07862 70.419 4.04422 70.9838C4.02988 71.2161 4.14884 71.2935 4.22052 71.3193C4.25349 71.3293 4.285 71.3365 4.3151 71.3365Z" fill="$paper" />
      <path d="M52.8205 36.9668C52.9381 36.9668 53.0327 36.8721 53.0327 36.7546C53.0327 36.637 52.9381 36.5424 52.8205 36.5424C48.2262 36.5424 43.2906 36.4622 38.517 36.3833C34.2868 36.3145 30.2916 36.25 26.9931 36.25C26.8756 36.25 26.7824 36.3446 26.7824 36.4622C26.7824 36.5797 26.8756 36.6743 26.9931 36.6743C30.2887 36.6743 34.281 36.7388 38.5099 36.8076C43.2863 36.885 48.2233 36.9668 52.8205 36.9668Z" fill="$paper" />
      <path d="M31.5788 39.7218C31.6348 39.7218 31.6921 39.6989 31.7336 39.6544C31.8139 39.5684 31.8096 39.4351 31.7236 39.3548C30.4807 38.1837 29.073 37.2175 27.5378 36.4792C29.2064 35.827 30.786 35.1389 32.0002 34.1641C32.0905 34.091 32.1063 33.9563 32.0318 33.866C31.9573 33.7757 31.8239 33.7599 31.7336 33.8344C30.4521 34.8608 28.7233 35.569 26.9171 36.2642C26.8368 36.2943 26.7823 36.3717 26.7809 36.4577C26.778 36.5437 26.8282 36.6226 26.907 36.657C28.5785 37.3995 30.1009 38.4116 31.4312 39.6659C31.4742 39.7032 31.5272 39.7218 31.5788 39.7218Z" fill="$paper" />
      <path d="M30.8337 52.6028C30.8566 52.6028 30.8796 52.5985 30.904 52.5914C32.67 51.9821 34.8346 51.3055 37.1268 50.5873C39.72 49.776 42.4006 48.9374 44.8719 48.0844C44.9823 48.0472 45.0426 47.9253 45.0039 47.815C44.9666 47.7046 44.8448 47.6458 44.7344 47.6831C42.2673 48.5346 39.5895 49.3717 36.9991 50.1831C34.7041 50.9013 32.5381 51.5793 30.7649 52.19C30.6545 52.2287 30.5943 52.3491 30.633 52.4595C30.6631 52.5484 30.7463 52.6028 30.8337 52.6028Z" fill="$paper" />
      <path d="M36.1579 53.9899C36.2396 53.9899 36.3156 53.944 36.3514 53.8652C36.4002 53.7591 36.3528 53.6329 36.2453 53.5842C34.6871 52.8818 33.0444 52.4274 31.3514 52.2295C32.7161 51.0684 33.9847 49.903 34.8162 48.5856C34.8778 48.4867 34.8477 48.3548 34.7488 48.2932C34.6513 48.2301 34.5194 48.2588 34.4563 48.3591C33.5819 49.7467 32.1771 50.981 30.6949 52.2281C30.6289 52.2826 30.6031 52.3729 30.6289 52.4546C30.6547 52.5377 30.7264 52.5951 30.8124 52.6023C32.6343 52.7599 34.4033 53.2215 36.0719 53.9727C36.0991 53.9842 36.1292 53.9899 36.1579 53.9899Z" fill="$paper" />
      <path d="M43.1335 25.7907C43.2267 25.7907 43.3127 25.729 43.3399 25.6344C43.37 25.5212 43.304 25.4036 43.1908 25.3735C40.6764 24.6869 37.9958 23.8698 35.4011 23.0799C33.0989 22.379 30.9229 21.7167 29.1109 21.2221C28.9962 21.192 28.8802 21.258 28.8486 21.3712C28.8185 21.4845 28.8845 21.6006 28.9977 21.6321C30.8025 22.1252 32.9742 22.7861 35.2765 23.487C37.8725 24.2769 40.5574 25.094 43.0761 25.7821C43.0962 25.7878 43.1163 25.7907 43.1335 25.7907Z" fill="$paper" />
      <path d="M32.6705 25.7857C32.7092 25.7857 32.7479 25.7757 32.7823 25.7556C32.8812 25.694 32.9142 25.5635 32.8525 25.4632C31.9609 24.0067 30.8585 22.7037 29.5727 21.5855C31.3559 21.3963 33.0618 21.1469 34.4882 20.5291C34.5957 20.4818 34.6444 20.357 34.5985 20.2495C34.5526 20.1406 34.4293 20.0918 34.3189 20.1391C32.8152 20.7914 30.9603 21.0193 29.0322 21.2143C28.9462 21.2229 28.8759 21.2816 28.8501 21.3634C28.8258 21.4465 28.853 21.5354 28.919 21.5898C30.3353 22.7481 31.538 24.1257 32.4913 25.6839C32.53 25.7499 32.5988 25.7857 32.6705 25.7857Z" fill="$paper" />
    </svg>''';
}

String eyeIconSvg(String color, String fill) {
  return ''' <svg width="92" height="38" viewBox="0 0 92 38" fill="none" xmlns="http://www.w3.org/2000/svg">
<path d="M41.6878 23.7499C41.6878 31.3785 36.819 37.2498 31.1566 37.2498C25.4943 37.2498 20.6255 31.3785 20.6255 23.7499C20.6255 16.1213 25.4943 10.25 31.1566 10.25C36.819 10.25 41.6878 16.1213 41.6878 23.7499Z" stroke="$color" stroke-width="1.5"/>
<path d="M66.6248 22.5624C66.6248 30.8315 61.2365 37.2498 54.9062 37.2498C48.5758 37.2498 43.1875 30.8315 43.1875 22.5624C43.1875 14.2932 48.5758 7.875 54.9062 7.875C61.2365 7.875 66.6248 14.2932 66.6248 22.5624Z" stroke="$color" stroke-width="1.5"/>
<ellipse cx="46.0001" cy="37.4062" rx="45.1246" ry="0.593745" fill="url(#paint0_linear_1385_190193)"/>
<ellipse cx="31.1567" cy="24.3437" rx="2.96873" ry="4.15622" fill="$fill"/>
<ellipse cx="53.7187" cy="24.3437" rx="2.96873" ry="5.34371" fill="$fill"/>
<path d="M17.6995 14.7481C21.1253 8.50578 25.9609 2.06361 38.0421 6.09684" stroke="$color"/>
<path d="M43.8481 7.59831C49.769 3.6429 57.0328 0.161199 65.887 9.3169" stroke="$color"/>
<defs>
<linearGradient id="paint0_linear_1385_190193" x1="3.18957" y1="37.4062" x2="79.5543" y2="37.4062" gradientUnits="userSpaceOnUse">
<stop stop-opacity="0.13" stop-color="$color"/>
<stop offset="0.208333" stop-color="$color"/>
<stop offset="0.526042" stop-color="$color"/>
<stop offset="0.734375" stop-opacity="0.89" stop-color="$color"/>
<stop offset="1" stop-opacity="0.04" stop-color="$color"/>
</linearGradient>
</defs>
</svg>''';
}

class EyeCareWhoWeAre extends StatefulWidget {
  const EyeCareWhoWeAre({super.key});

  @override
  State<EyeCareWhoWeAre> createState() => _EyeCareWhoWeAreState();
}

class _EyeCareWhoWeAreState extends State<EyeCareWhoWeAre> {
  @override
  Widget build(BuildContext context) {
    var homeThemeName = Provider.of<ThemeProvider>(context).homeThemeName;
    String primaryColor = primaryColorCodeReturn(homeThemeName);
    var brightness = Theme.of(context).brightness;
    return Column(
      children: [
        Center(
          child: SvgPicture.string(
            eyeIconSvg(brightness == Brightness.dark ? '#fff' : '#000', "#$primaryColor"),
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                    text: context.tr('who').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).primaryColorLight, fontSize: 34, fontWeight: FontWeight.bold)),
                const TextSpan(text: '  '),
                TextSpan(
                    text: context.tr('weAre').toUpperCase(),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 34, fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          context.tr('eyeGreatPlace'),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        Container(
          height: 400,
          width: 400,
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.contain,
              colorFilter: ColorFilter.mode(Colors.black.withAlpha((0.2 * 255).round()), BlendMode.dstATop),
              image: const NetworkImage('https://health-care.duckdns.org/assets/images/hospital.webp'),
            ),
          ),
        ),
      ],
    );
  }
}
