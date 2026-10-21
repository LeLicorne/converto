import 'package:flutter/widgets.dart';

const wideBreakpoint = 840.0;
const contentMaxWidthNarrow = 640.0;
const contentMaxWidthWide = 1040.0;

bool isWideLayout(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= wideBreakpoint;

double contentMaxWidth(BuildContext context) =>
    isWideLayout(context) ? contentMaxWidthWide : contentMaxWidthNarrow;
