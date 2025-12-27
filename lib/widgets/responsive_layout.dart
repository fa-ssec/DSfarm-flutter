/// Responsive Layout Widget
/// 
/// Widget untuk responsive breakpoints di mobile, tablet, dan desktop.

library;

import 'package:flutter/material.dart';

/// Breakpoints
class Breakpoints {
  static const double mobile = 600;
  static const double tablet = 1200;
  
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobile;
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobile && width < tablet;
  }
  
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= tablet;
  
  static bool isNotMobile(BuildContext context) =>
      MediaQuery.of(context).size.width >= mobile;
}

/// Responsive Layout Widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= Breakpoints.tablet) {
          return desktop ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          return tablet ?? mobile;
        }
        return mobile;
      },
    );
  }
}

/// Responsive Grid View
class ResponsiveGridView extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final double childAspectRatio;
  final EdgeInsets? padding;

  const ResponsiveGridView({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.crossAxisSpacing = 12,
    this.mainAxisSpacing = 12,
    this.childAspectRatio = 1.0,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        int columns;
        if (constraints.maxWidth >= Breakpoints.tablet) {
          columns = desktopColumns;
        } else if (constraints.maxWidth >= Breakpoints.mobile) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }

        return GridView.count(
          crossAxisCount: columns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
          childAspectRatio: childAspectRatio,
          padding: padding ?? const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: children,
        );
      },
    );
  }
}

/// Responsive Padding
class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final EdgeInsets mobile;
  final EdgeInsets? tablet;
  final EdgeInsets? desktop;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.mobile = const EdgeInsets.all(16),
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding;
    if (Breakpoints.isDesktop(context)) {
      padding = desktop ?? tablet ?? mobile;
    } else if (Breakpoints.isTablet(context)) {
      padding = tablet ?? mobile;
    } else {
      padding = mobile;
    }

    return Padding(
      padding: padding,
      child: child,
    );
  }
}

/// Responsive Width Container
class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsets padding;
  final bool center;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth = 1200,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.center = true,
  });

  @override
  Widget build(BuildContext context) {
    return center
        ? Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              padding: padding,
              child: child,
            ),
          )
        : Container(
            constraints: BoxConstraints(maxWidth: maxWidth),
            padding: padding,
            child: child,
          );
  }
}

/// Responsive Value Helper
T responsiveValue<T>(
  BuildContext context, {
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  if (Breakpoints.isDesktop(context)) {
    return desktop ?? tablet ?? mobile;
  } else if (Breakpoints.isTablet(context)) {
    return tablet ?? mobile;
  }
  return mobile;
}

/// Responsive Columns untuk Dashboard
class ResponsiveColumns extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  final double spacing;

  const ResponsiveColumns({
    super.key,
    required this.children,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.spacing = 16,
  });

  @override
  Widget build(BuildContext context) {
    final columns = responsiveValue(
      context,
      mobile: mobileColumns,
      tablet: tabletColumns,
      desktop: desktopColumns,
    );

    if (columns == 1) {
      return Column(
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: spacing),
          child: child,
        )).toList(),
      );
    }

    // Build rows for multi-column layout
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += columns) {
      final rowChildren = <Widget>[];
      for (int j = 0; j < columns && i + j < children.length; j++) {
        if (j > 0) rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(Expanded(child: children[i + j]));
      }
      // Fill remaining columns with empty expanded
      while (rowChildren.length < columns * 2 - 1) {
        rowChildren.add(SizedBox(width: spacing));
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(Padding(
        padding: EdgeInsets.only(bottom: spacing),
        child: Row(children: rowChildren),
      ));
    }

    return Column(children: rows);
  }
}
