import 'package:flutter/material.dart';

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, BoxConstraints constraints) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return builder(context, constraints);
      },
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? mobile;
  final double? tablet;
  final double? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = 16.0,
    this.tablet = 24.0,
    this.desktop = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double padding;
        if (constraints.maxWidth < 600) {
          padding = mobile!;
        } else if (constraints.maxWidth < 900) {
          padding = tablet!;
        } else {
          padding = desktop!;
        }

        return Padding(
          padding: EdgeInsets.all(padding),
          child: child,
        );
      },
    );
  }
}

class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final double? spacing;
  final int? mobileColumns;
  final int? tabletColumns;
  final int? desktopColumns;
  final double childAspectRatio;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.spacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.childAspectRatio = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth < 600) {
          columns = mobileColumns!;
        } else if (constraints.maxWidth < 900) {
          columns = tabletColumns!;
        } else {
          columns = desktopColumns!;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: spacing!,
          mainAxisSpacing: spacing!,
          childAspectRatio: childAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If mobile, switch to Column
        if (constraints.maxWidth < 600) {
          return Column(
            mainAxisAlignment: mainAxisAlignment,
            crossAxisAlignment: crossAxisAlignment,
            children: _addSpacing(children, spacing, isVertical: true),
          );
        }

        // Otherwise use Row
        return Row(
          mainAxisAlignment: mainAxisAlignment,
          crossAxisAlignment: crossAxisAlignment,
          children: _addSpacing(children, spacing, isVertical: false),
        );
      },
    );
  }

  List<Widget> _addSpacing(List<Widget> children, double spacing, {required bool isVertical}) {
    if (children.isEmpty) return children;

    final List<Widget> spacedChildren = [];
    for (int i = 0; i < children.length; i++) {
      spacedChildren.add(children[i]);
      if (i < children.length - 1) {
        spacedChildren.add(
          isVertical
              ? SizedBox(height: spacing)
              : SizedBox(width: spacing),
        );
      }
    }
    return spacedChildren;
  }
}

class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900 && desktop != null) {
      return desktop!;
    } else if (width >= 600 && tablet != null) {
      return tablet!;
    }
    return mobile;
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Widget? drawer;

  const AdaptiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.drawer,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For mobile, use standard Scaffold
        if (constraints.maxWidth < 600) {
          return Scaffold(
            appBar: appBar,
            body: SafeArea(child: body),
            floatingActionButton: floatingActionButton,
            bottomNavigationBar: bottomNavigationBar,
            drawer: drawer,
          );
        }

        // For tablet/desktop, use more spacious layout
        return Scaffold(
          appBar: appBar,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth < 900 ? 800 : 1200,
                ),
                child: body,
              ),
            ),
          ),
          floatingActionButton: floatingActionButton,
          bottomNavigationBar: bottomNavigationBar,
          drawer: drawer,
        );
      },
    );
  }
}

extension ResponsiveExtension on BuildContext {
  bool get isMobile => MediaQuery.of(this).size.width < 600;
  bool get isTablet => MediaQuery.of(this).size.width >= 600 && MediaQuery.of(this).size.width < 900;
  bool get isDesktop => MediaQuery.of(this).size.width >= 900;

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    final width = MediaQuery.of(this).size.width;
    if (width >= 900 && desktop != null) {
      return desktop;
    } else if (width >= 600 && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}