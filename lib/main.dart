import 'dart:ui';

import 'package:age_calculator/age_calculator.dart';
import 'package:faker/faker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

void main() => runApp(const App());

class Dimensions {
  static const xScrollable = 16.0;
  static const borderRadius = 12.0;
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: const DefaultTextStyle(
        style: TextStyle(color: CupertinoColors.white),
        child: Home(),
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

extension TextThemeExtension on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}

extension TextSpanExtension on TextSpan {
  RichText get richText => RichText(text: this);
}

extension WidgetExtension on Widget {
  SliverToBoxAdapter get sliver => SliverToBoxAdapter(child: this);
}

class PetCard extends StatelessWidget {
  const PetCard(this.pet, {super.key});

  final Pet pet;

  static const spacing = SizedBox(width: 12);

  Widget infoRow(Widget icon, Widget description) {
    return Row(children: [icon, spacing, description]);
  }

  @override
  Widget build(BuildContext context) {
    final decoration = BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.bottomLeft,
        end: Alignment.topRight,
        colors: [CupertinoColors.systemPurple, CupertinoColors.systemBlue],
      ),
      borderRadius: BorderRadius.circular(Dimensions.borderRadius),
    );

    final titleStyle = context.textTheme.headlineSmall!.copyWith(
      fontWeight: FontWeight.w600,
    );

    Icon icon(IconData data) => Icon(
          data,
          color: CupertinoColors.white.withOpacity(0.7),
        );

    final nameInfo = infoRow(
      icon(CupertinoIcons.tag_fill),
      Text(pet.name, style: titleStyle),
    );

    final birthInfo = infoRow(
      Transform.translate(
        offset: const Offset(0, -3),
        child: icon(Icons.cake_rounded),
      ),
      Text(
          '${DateFormat.yMMMd().format(pet.birthday)} (${AgeCalculator.age(pet.birthday).years} yo)'),
    );

    final microchipInfo = infoRow(
      icon(MdiIcons.chip),
      Text(pet.microchip),
    );

    final race = infoRow(
      icon(MdiIcons.dog),
      Text(pet.breed),
    );

    Widget child = Column(children: [
      nameInfo,
      const Divider(
        color: CupertinoColors.white,
        height: 28,
        indent: 36,
      ),
      birthInfo,
      microchipInfo,
      race,
    ]);

    return Container(
      decoration: decoration,
      clipBehavior: Clip.hardEdge,
      child: Padding(padding: const EdgeInsets.all(16), child: child),
    );
  }
}

class Pet {
  Pet({
    required this.name,
    required this.microchip,
    required this.birthday,
    required this.breed,
  });

  final String name;
  final String microchip;
  final DateTime birthday;
  final String breed;
}

class PetGenerator {
  Pet call(int seed) {
    final faker = Faker(seed: seed);
    return Pet(
      name: faker.person.lastName(),
      birthday: faker.date.dateTime(minYear: 2015, maxYear: 2022),
      breed: 'Schnauzer',
      microchip: faker.randomGenerator.numberOfLength(15),
    );
  }
}

class _HomeState extends State<Home> {
  final dashboardTitleKey = GlobalKey(debugLabel: 'Dashboard-scrollable-title');

  static const _bottomBarHeight = 80.0;
  static const _appBarHeight = 100.0;
  static const _petCardPadding = 8.0;

  final scrollController = ScrollController();
  final pets = <Pet>[];

  final isScrolled = ValueNotifier<bool>(false);
  final showNavigatorTitle = ValueNotifier<bool>(false);

  void scrollListener() {
    final titleHeight = dashboardTitleKey.currentContext?.size?.height ?? 0;

    if (scrollController.offset > titleHeight - 8) {
      showNavigatorTitle.value = true;
    } else {
      showNavigatorTitle.value = false;
    }

    if (scrollController.position.pixels <
        scrollController.position.maxScrollExtent - _petCardPadding) {
      isScrolled.value = true;
    } else {
      isScrolled.value = false;
    }
  }

  @override
  void initState() {
    super.initState();
    pets.addAll(List.generate(6, (i) => PetGenerator()(i)));

    scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    final appBar = IOSAppBar(
      title: 'Dashboard',
      height: _appBarHeight,
      showTitle: showNavigatorTitle,
    );

    final sectionTitle = SliverToBoxAdapter(
      child: Padding(
        key: dashboardTitleKey,
        padding: const EdgeInsets.symmetric(horizontal: Dimensions.xScrollable),
        child: ValueListenableBuilder(
          valueListenable: showNavigatorTitle,
          builder: (_, isHidden, __) {
            final style = context.textTheme.headlineMedium!.copyWith(
              color: CupertinoColors.white,
              fontWeight: FontWeight.bold,
            );

            return isHidden
                ? Text('', key: const ValueKey('Hidden'), style: style)
                : Text('Dashboard',
                    key: const ValueKey('Visible'), style: style);
          },
        ),
      ),
    );

    final list = SliverList(
      delegate: SliverChildBuilderDelegate(
        (_, i) => Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 10,
            horizontal: Dimensions.xScrollable,
          ),
          child: PetCard(pets[i]),
        ),
        childCount: pets.length,
      ),
    );

    final bottomBar = ValueListenableBuilder(
      valueListenable: isScrolled,
      builder: (_, isScrolled, child) {
        return MaterialSurface(
          blur: isScrolled ? 12 : 0,
          background: isScrolled
              ? CupertinoColors.darkBackgroundGray.withOpacity(0.9)
              : CupertinoColors.black,
          child: child!,
        );
      },
      child: const BottomBar(
        height: _bottomBarHeight,
        children: [
          LabeledIcon(
            icon: CupertinoIcons.circle_grid_3x3_fill,
            isActive: true,
            label: Text('Dashboard'),
          ),
          LabeledIcon(
            icon: CupertinoIcons.person_fill,
            isActive: false,
            label: Text('Profile'),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: CupertinoColors.black,
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      body: Scrollbar(
        controller: scrollController,
        child: CustomScrollView(
          controller: scrollController,
          slivers: [
            const SliverToBoxAdapter(child: SizedBox(height: _appBarHeight)),
            sectionTitle,
            list,
            const SliverToBoxAdapter(child: SizedBox(height: _bottomBarHeight))
          ],
        ),
      ),
      bottomNavigationBar: bottomBar,
    );
  }
}

class MaterialSurface extends StatelessWidget {
  const MaterialSurface({
    required this.blur,
    required this.background,
    required this.child,
    super.key,
  });

  final double blur;
  final Color background;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(
            sigmaX: blur, sigmaY: blur, tileMode: TileMode.mirror),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: background,
          child: child,
        ),
      ),
    );
  }
}

class BottomBar extends StatelessWidget {
  const BottomBar({
    required this.children,
    required this.height,
    super.key,
  });

  final List<Widget> children;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.only(top: 12),
      child: Row(
        children: [...children.map((e) => Expanded(child: e))],
      ),
    );
  }
}

class LabeledIcon extends StatelessWidget {
  const LabeledIcon({
    required this.icon,
    required this.label,
    required this.isActive,
    super.key,
  });

  final IconData icon;
  final Widget label;
  final bool isActive;

  Color get foreground {
    return isActive ? CupertinoColors.activeBlue : CupertinoColors.inactiveGray;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: TextStyle(color: foreground, fontSize: 11),
      child: Column(
        children: [
          Icon(icon, color: foreground),
          const SizedBox(height: 2),
          label
        ],
      ),
    );
  }
}

class IOSAppBar extends StatefulWidget implements PreferredSizeWidget {
  const IOSAppBar({
    required this.title,
    required this.showTitle,
    required this.height,
    super.key,
  });

  final String title;
  final double height;
  final ValueNotifier<bool> showTitle;

  @override
  State<IOSAppBar> createState() => _IOSAppBarState();

  @override
  Size get preferredSize => Size(double.infinity, height);
}

class _IOSAppBarState extends State<IOSAppBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
      reverseDuration: const Duration(milliseconds: 500),
    );

    controller.drive(CurveTween(curve: Curves.easeInOut));

    widget.showTitle.addListener(() {
      if (!mounted) return;
      if (widget.showTitle.value) {
        controller.forward();
      } else {
        controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle =
        context.textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    return ClipRRect(
      clipBehavior: Clip.hardEdge,
      child: AnimatedBuilder(
        animation: controller,
        builder: (_, ___) {
          return MaterialSurface(
            background: Color.alphaBlend(
              Colors.black.withOpacity((1 - controller.value)),
              CupertinoColors.darkBackgroundGray
                  .withOpacity(0.6 + 0.4 * (1 - controller.value)),
            ),
            blur: 20,
            child: Container(
              height: widget.height,
              alignment: Alignment.center,
              child: SafeArea(
                minimum: const EdgeInsets.only(bottom: 10),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: widget.showTitle.value
                      ? Text(
                          widget.title,
                          key: const ValueKey('IOSAppBar-title'),
                          style: textStyle,
                        )
                      : const SizedBox(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
