import 'package:flutter/widgets.dart';

class AutoSizeText extends StatefulWidget {
  const AutoSizeText(
    this.data, {
    Key key,
    this.style,
    this.strutStyle,
    this.minFontSize = 12,
    this.maxFontSize = double.infinity,
    this.stepGranularity = 1,
    this.textAlign,
    this.textDirection,
    this.softWrap,
    this.wrapWords = true,
    this.maxLines,
  })  : assert(data != null,
            'A non-null String must be provided to a AutoSizeText widget.'),
        super(key: key);

  static const double _defaultFontSize = 14.0;

  final String data;
  final TextStyle style;
  final StrutStyle strutStyle;
  final double minFontSize;
  final double maxFontSize;
  final double stepGranularity;
  final TextAlign textAlign;
  final TextDirection textDirection;
  final bool softWrap;
  final bool wrapWords;
  final int maxLines;

  @override
  _AutoSizeTextState createState() => _AutoSizeTextState();
}

class _AutoSizeTextState extends State<AutoSizeText> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, size) {
      DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);

      TextStyle style = widget.style;
      if (widget.style == null || widget.style.inherit) {
        style = defaultTextStyle.style.merge(widget.style);
      }
      if (style.fontSize == null) {
        style = style.copyWith(fontSize: AutoSizeText._defaultFontSize);
      }

      var maxLines = widget.maxLines ?? defaultTextStyle.maxLines;

      _sanityCheck(style, maxLines);

      return Text(widget.data,
          style: style.copyWith(
              fontSize: _calculateFontSize(size, style, maxLines)),
          strutStyle: widget.strutStyle,
          textAlign: widget.textAlign,
          textDirection: widget.textDirection,
          softWrap: widget.softWrap,
          maxLines: maxLines);
    });
  }

  void _sanityCheck(TextStyle style, int maxLines) {
    assert(maxLines == null || maxLines > 0,
        "MaxLines has to be grater than or equal to 1.");

    assert(widget.stepGranularity >= 0.1,
        'StepGranularity has to be greater than or equal to 0.1. It is not a good idea to resize the font with a higher accuracy.');
    assert(widget.minFontSize >= 0,
        "MinFontSize has to be greater than or equal to 0.");
    assert(widget.maxFontSize > 0, "MaxFontSize has to be greater than 0.");
    assert(widget.minFontSize <= widget.maxFontSize,
        "MinFontSize has to be smaller or equal than maxFontSize.");
    assert(widget.minFontSize / widget.stepGranularity % 1 == 0,
        "MinFontSize has to be multiples of stepGranularity.");
    if (widget.maxFontSize != double.infinity) {
      assert(widget.maxFontSize / widget.stepGranularity % 1 == 0,
          "MaxFontSize has to be multiples of stepGranularity.");
    }
    assert(style.fontSize / widget.stepGranularity % 1 == 0,
        "FontSize has to be multiples of stepGranularity.");
  }

  double _calculateFontSize(
      BoxConstraints size, TextStyle style, int maxLines) {
    var span = TextSpan(style: style, text: widget.data);

    int left = (widget.minFontSize / widget.stepGranularity).round();
    var initialFontSize =
        style.fontSize.clamp(widget.minFontSize, widget.maxFontSize);
    int right = (initialFontSize / widget.stepGranularity).round();

    var userScale = MediaQuery.textScaleFactorOf(context);

    bool _testValue(int value) {
      double scale =
          value * userScale * widget.stepGranularity / style.fontSize;
      return _checkTextFits(span, scale, maxLines, size);
    }

    bool lastValueFits = false;
    if (_testValue(right)) {
      lastValueFits = true;
    } else {
      right -= 1;
      while (left <= right) {
        int mid = (left + (right - left) / 2).toInt();
        if (_testValue(mid)) {
          left = mid + 1;
          lastValueFits = true;
        } else {
          right = mid - 1;
        }
      }

      if (!lastValueFits) right += 1;
    }

    return right * userScale * widget.stepGranularity;
  }

  bool _checkTextFits(
      TextSpan text, double scale, int maxLines, BoxConstraints constraints) {
    if (!widget.wrapWords) {
      var wordCount = text.toPlainText().split(RegExp('\\s+')).length;
      maxLines = maxLines == null ? wordCount : maxLines.clamp(1, wordCount);
    }

    var tp = TextPainter(
      text: text,
      textAlign: widget.textAlign ?? TextAlign.left,
      textDirection: widget.textDirection ?? TextDirection.ltr,
      textScaleFactor: scale ?? 1,
      maxLines: maxLines,
      strutStyle: widget.strutStyle,
    );

    tp.layout(maxWidth: constraints.maxWidth);

    return !(tp.didExceedMaxLines ||
        tp.height > constraints.maxHeight ||
        tp.width > constraints.maxWidth);
  }
}
