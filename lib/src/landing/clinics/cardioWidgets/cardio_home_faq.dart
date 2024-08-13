
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:health_care/src/utils/hex_to_color.dart';

class CardioHomeFaq extends StatefulWidget {
  final double cardioHomeFAQHeight;
  const CardioHomeFaq({
    super.key,
    required this.cardioHomeFAQHeight,
  });

  @override
  State<CardioHomeFaq> createState() => _CardioHomeFaqState();
}

class _CardioHomeFaqState extends State<CardioHomeFaq> {
  double firstHeight = 0;
  bool firstOpen = false;
  double secondHeight = 0;
  bool secondOpen = false;
  double thirdHeight = 0;
  bool thirdOpen = false;
  double forthHeight = 0;
  bool forthOpen = false;
  double fifthHeight = 0;
  bool fifthOpen = false;

  @override
  void didChangeDependencies() {
    firstHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
    secondHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
    thirdHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
    forthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
    fifthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
    super.didChangeDependencies();
  }

  void sizeChange(String componentName) {
    switch (componentName) {
      case 'first':
        setState(() {
          firstHeight = firstHeight == ((widget.cardioHomeFAQHeight * 0.607) / 5)
              ? ((widget.cardioHomeFAQHeight * 0.607) / 5) * 2
              : ((widget.cardioHomeFAQHeight * 0.607) / 5);
          firstOpen = !firstOpen;
          secondOpen = false;
          thirdOpen = false;
          forthOpen = false;
          fifthOpen = false;
          secondHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          thirdHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          forthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          fifthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
        });
        break;
      case 'second':
        setState(() {
          secondHeight = secondHeight == ((widget.cardioHomeFAQHeight * 0.607) / 5)
              ? ((widget.cardioHomeFAQHeight * 0.607) / 5) * 2
              : ((widget.cardioHomeFAQHeight * 0.607) / 5);
          secondOpen = !secondOpen;
          firstOpen = false;
          thirdOpen = false;
          forthOpen = false;
          fifthOpen = false;
          firstHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          thirdHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          forthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          fifthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
        });
      case 'third':
        setState(() {
          thirdHeight = thirdHeight == ((widget.cardioHomeFAQHeight * 0.607) / 5)
              ? ((widget.cardioHomeFAQHeight * 0.607) / 5) * 2
              : ((widget.cardioHomeFAQHeight * 0.607) / 5);
          thirdOpen = !thirdOpen;
          firstOpen = false;
          secondOpen = false;
          forthOpen = false;
          fifthOpen = false;
          firstHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          secondHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          forthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          fifthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
        });
      case 'forth':
        setState(() {
          forthHeight = forthHeight == ((widget.cardioHomeFAQHeight * 0.607) / 5)
              ? ((widget.cardioHomeFAQHeight * 0.607) / 5) * 2
              : ((widget.cardioHomeFAQHeight * 0.607) / 5);
          forthOpen = !forthOpen;
          firstOpen = false;
          secondOpen = false;
          thirdOpen = false;
          fifthOpen = false;
          firstHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          secondHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          thirdHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          fifthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
        });
      case 'fifth':
        setState(() {
          fifthHeight = fifthHeight == ((widget.cardioHomeFAQHeight * 0.607) / 5)
              ? ((widget.cardioHomeFAQHeight * 0.607) / 5) * 2
              : ((widget.cardioHomeFAQHeight * 0.607) / 5);
          fifthOpen = !fifthOpen;
          firstOpen = false;
          secondOpen = false;
          thirdOpen = false;
          forthOpen = false;
          firstHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          secondHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          thirdHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
          forthHeight = ((widget.cardioHomeFAQHeight * 0.607) / 5);
        });
      default:
    }
  }

  double getTop(String componentName) {
    double top = 0;
    switch (componentName) {
      case 'second':
        top = firstOpen ? firstHeight + 16 : ((widget.cardioHomeFAQHeight * 0.607) / 5) + 16;
        break;
      case 'third':
        top = firstOpen
            ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 2) - 8) + secondHeight
            : secondOpen
                ? ((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) + 8) + secondHeight
                : ((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 2) - 8;
        break;
      case 'forth':
        top = firstOpen
            ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 3) - 8) + secondHeight
            : secondOpen
                ? ((((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16)) + 8) + secondHeight) + (thirdHeight + 8)
                : thirdOpen
                    ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 2) - 16) + (thirdHeight + 16)
                    : ((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 3) - 16;
        break;
      case 'fifth':
        top = firstOpen
            ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 4) - 8) + secondHeight
            : secondOpen
                ? ((((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16)) + 8) + secondHeight) + (thirdHeight + 8) + (forthHeight + 8)
                : thirdOpen
                    ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 2) - 16) + (thirdHeight + 16) + (forthHeight + 8)
                    : forthOpen
                        ? (((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 2) - 16) + (thirdHeight + 16) + (forthHeight + 8)
                        : ((((widget.cardioHomeFAQHeight * 0.607) / 5) + 16) * 4) - 24;
        break;
      default:
        top = firstOpen || secondOpen || thirdOpen || forthOpen || fifthOpen
            ? (widget.cardioHomeFAQHeight * 0.8) + 24
            : widget.cardioHomeFAQHeight * 0.69;
        break;
    }
    return top;
  }

  @override
  Widget build(BuildContext context) {
            var shortestSide = MediaQuery.of(context).size.shortestSide;

// Determine if we should use mobile layout or not, 600 here is
// a common breakpoint for a typical 7-inch tablet.
    final bool useMobileLayout = shortestSide < 600;
    return Positioned(
      top: useMobileLayout ? MediaQuery.of(context).size.height < 700 ? 4400 : 4300 : 4800,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: widget.cardioHomeFAQHeight * 2,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                dense: true,
                title: Text(
                  context.tr('cardioFaq'),
                  style: GoogleFonts.robotoCondensed(
                    fontSize: 30.0,
                    color: Theme.of(context).primaryColorLight,
                  ),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width,
                height: getTop('main'),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Stack(
                  children: [
                    Container(
                      clipBehavior: Clip.hardEdge,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          opacity: 0.3,
                          image: NetworkImage(
                            '${dotenv.env['webUrl']}/assets/images/faq-img-2.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          sizeChange('first');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: firstHeight,
                          width: MediaQuery.of(context).size.width - 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? hexToColor('#424242') : hexToColor('#EEEEEE'),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: firstOpen ? const Icon(Icons.remove) : const Icon(Icons.add),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: AnimatedCrossFade(
                                  firstChild: Text(
                                    firstOpen ? '' : context.tr('cardioFaqTitle1'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                  ),
                                  secondChild: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.tr('cardioFaqTitle1'),
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Theme.of(context).primaryColor, endIndent: 7),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(context.tr('lorem')),
                                        )
                                      ],
                                    ),
                                  ),
                                  crossFadeState: firstOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      top: getTop('second'),
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          sizeChange('second');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: secondHeight,
                          width: MediaQuery.of(context).size.width - 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? hexToColor('#424242') : hexToColor('#EEEEEE'),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: secondOpen ? const Icon(Icons.remove) : const Icon(Icons.add),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: AnimatedCrossFade(
                                  firstChild: Text(
                                    secondOpen ? '' : context.tr('cardioFaqTitle2'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                  ),
                                  secondChild: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.tr('cardioFaqTitle2'),
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Theme.of(context).primaryColor, endIndent: 7),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(context.tr('lorem')),
                                        )
                                      ],
                                    ),
                                  ),
                                  crossFadeState: secondOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      // top: firstOpen ?   firstHeight  +16: ((widget.cardioHomeFAQHeight * 0.607) / 5) +16,
                      top: getTop('third'),
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          sizeChange('third');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: thirdHeight,
                          width: MediaQuery.of(context).size.width - 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? hexToColor('#424242') : hexToColor('#EEEEEE'),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: thirdOpen ? const Icon(Icons.remove) : const Icon(Icons.add),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: AnimatedCrossFade(
                                  firstChild: Text(
                                    thirdOpen ? '' : context.tr('cardioFaqTitle3'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                  ),
                                  secondChild: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.tr('cardioFaqTitle3'),
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Theme.of(context).primaryColor, endIndent: 7),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(context.tr('lorem')),
                                        )
                                      ],
                                    ),
                                  ),
                                  crossFadeState: thirdOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      top: getTop('forth'),
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          sizeChange('forth');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: forthHeight,
                          width: MediaQuery.of(context).size.width - 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? hexToColor('#424242') : hexToColor('#EEEEEE'),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: forthOpen ? const Icon(Icons.remove) : const Icon(Icons.add),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: AnimatedCrossFade(
                                  firstChild: Text(
                                    forthOpen ? '' : context.tr('cardioFaqTitle1'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                  ),
                                  secondChild: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.tr('cardioFaqTitle1'),
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Theme.of(context).primaryColor, endIndent: 7),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(context.tr('lorem')),
                                        )
                                      ],
                                    ),
                                  ),
                                  crossFadeState: forthOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      top: getTop('fifth'),
                      left: 8,
                      child: GestureDetector(
                        onTap: () {
                          sizeChange('fifth');
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: fifthHeight,
                          width: MediaQuery.of(context).size.width - 34,
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark ? hexToColor('#424242') : hexToColor('#EEEEEE'),
                            border: Border.all(color: Theme.of(context).primaryColor, width: 2.0),
                            borderRadius: const BorderRadius.horizontal(
                              left: Radius.circular(50),
                              right: Radius.circular(50),
                            ),
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                                child: fifthOpen ? const Icon(Icons.remove) : const Icon(Icons.add),
                              ),
                              VerticalDivider(
                                color: Theme.of(context).primaryColor,
                                indent: 15,
                                endIndent: 15,
                              ),
                              Flexible(
                                fit: FlexFit.loose,
                                child: AnimatedCrossFade(
                                  firstChild: Text(
                                    fifthOpen ? '' : context.tr('cardioFaqTitle3'),
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                  ),
                                  secondChild: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(
                                            context.tr('cardioFaqTitle3'),
                                            overflow: TextOverflow.visible,
                                            style: TextStyle(fontSize: 18, color: Theme.of(context).primaryColorLight),
                                          ),
                                        ),
                                        Divider(thickness: 2, color: Theme.of(context).primaryColor, endIndent: 7),
                                        Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Text(context.tr('lorem')),
                                        )
                                      ],
                                    ),
                                  ),
                                  crossFadeState: fifthOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 500),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
