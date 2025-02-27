/**
 * 参考：https://pub.dev/packages/flutter_markdown_latex
 * 
 * 匹配的规则是：
 * 
 * inline：
 * - $...$ 其中 ... 为除了`$`外的任意字符，但是可以为`\$`，即转义
 * - \(...\) 要求 \( 与 \) 最小的匹配，即非贪心的，里面可以有(, )
 * 
 * block：
 * - $$...$$ 其中 ... 为除了`$`外的任意字符，但是可以为`\$`，即转义
 * - \[...\] 要求 \[ 与 \] 最小的匹配，即非贪心的
 * 
 * 支持换行，但是不能连续换行
 * 
 * 要注意 $$...$$ 不会被解析为行内公式，而是行间公式
 * 
 * ## version 1
 * 
 * inline: \$(?:\\\$|[^$]|\n(?!\n))+?\$|\\\((?:[^\\(]|\n(?!\n))+?\\\)
 * block: \$\$(?:\\\$|[^$]|\n(?!\n))+\$\$|\\\[(?:[^\\[]|\n(?!\n))+?\\\]
 * 
 * 
 */

part of 'markdown.dart';

// const _pattern = 
//       r'\$((?:\\\$|[^$]|\n(?!\n))+?)\$'
//   '|'
//       r'\\\(((?:[^\\(]|\n(?!\n))+?)\\\)'
//   '|'
//       r'\$\$((?:\\\$|[^$]|\n(?!\n))+?)\$\$'
//   '|'
//       r'\\\[((?:[^\\[]|\n(?!\n))+?)\\\]'
//   ;

// class TexSyntax extends MdInlineSyntax {
//   TexSyntax() : super(RegExp(_pattern, dotAll: true));

//   @override
//   MdInlineObject? parse(MdInlineParser parser, Match match) {
//     final texContent = match[1] ?? match[2] ?? match[3] ?? match[4];

//     if (texContent == null) {
//       return null;
//     }
    
//     final markers = parser.consumeBy(match[0]!.length);

//     final display = match[1] != null
//                   ? 'inline'
//                   : match[2] != null
//                   ? 'inline'
//                   : match[3] != null
//                   ? 'block'
//                   : match[4] != null
//                   ? 'block'
//                   : 'inline';

//     return MdInlineElement(
//       'mathTex',
//       markers: markers,
//       attributes: {
//         'display': display,
//         'content': texContent,
//       },
//       // children: [Text],
//       start: markers.single.start,
//       end: markers.single.end,
//     );
//   }
// }

// /// 参考这个实现：https://pub.dev/packages/flutter_markdown_latex
// /// 
// // class TexBlockSyntax extends MdBlockSyntax {
// //   TexBlockSyntax();

// //   @override
// //   RegExp get pattern => RegExp(r'\$\$(?:\\\$|[^$]|\n(?!\n))+\$\$|\\\[(?:[^\\[]|\n(?!\n))+?\\\]', dotAll: true);

// //   @override
// //   List<MdLine> parseChildLines(MdBlockParser parser) {
// //     final m = pattern.firstMatch(parser.current.content.text);
// //     if (m?[2] != null) {
// //       parser.advance();
// //       return [Line(m?[2] ?? '')];
// //     }

// //     final childLines = <Line>[];
// //     parser.advance();

// //     while (!parser.isDone) {
// //       final match = pattern.hasMatch(parser.current.content.text);
// //       if (!match) {
// //         childLines.add(parser.current);
// //         parser.advance();
// //       } else {
// //         parser.advance();
// //         break;
// //       }
// //     }

// //     return childLines;
// //   }

// //   @override
// //   MdBlockElement parse(MdBlockParser parser) {
// //     final lines = parseChildLines(parser);
// //     final content = lines.map((e) => e.content).join('\n').trim();
// //     final textElement = MdElement.text('latex', content);
// //     textElement.attributes['MathStyle'] = 'display';

// //     return MdBlockElement('p', [textElement]);
// //   }
// // }


// class TexBuilder extends MarkdownElementBuilder {
//   TexBuilder();

//   @override
//   bool isBlock(element) => true;

//   @override
//   List<String> matchTypes = <String>['mathTex'];

//   @override 
//   Widget? buildWidget(element, parent) {
//     if (element.attributes['display'] == 'inline') {
//       return Math.tex(
//         element.attributes['content']!,
//         mathStyle: MathStyle.text,
//       );
//     } if (element.attributes['display'] == 'block') {
//       return Center(
//         child: SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           clipBehavior: Clip.antiAlias,
//           child: Math.tex(
//             element.attributes['content']!,
//             mathStyle: MathStyle.display,
//           )
//         )
//       );
//     } else {
//       return null;
//     }
//   }
// }

/// 使得数学公式居中
class LatexElementBuilderFixed extends LatexElementBuilder {
  @override
  Widget visitElementAfterWithContext(
    BuildContext context,
    md.Element element,
    TextStyle? preferredStyle,
    TextStyle? parentStyle,
  ) {
    final superResult = super.visitElementAfterWithContext(context, element, preferredStyle, parentStyle);
    return switch(element.attributes['MathStyle']) {
      'display' => Align(alignment: Alignment.topCenter, child: superResult),
      _ => superResult,
    };
  }
}