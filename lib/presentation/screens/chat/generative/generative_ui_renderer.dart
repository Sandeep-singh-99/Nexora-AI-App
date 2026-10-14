import 'package:flutter/material.dart';
import 'chart_card.dart';
import 'data_table_card.dart';
import 'info_card.dart';
import 'math_card.dart';
import 'search_results_card.dart';
import 'time_card.dart';
import 'youtube_card.dart';

class GenerativeUIRenderer extends StatelessWidget {
  final Map<String, dynamic> uiPayload;
  final void Function(String prompt)? onPromptTap;

  const GenerativeUIRenderer({
    super.key,
    required this.uiPayload,
    this.onPromptTap,
  });

  @override
  Widget build(BuildContext context) {
    final type = (uiPayload['type'] ?? uiPayload['name'] ?? '').toString().toLowerCase();
    final props = (uiPayload['props'] as Map<String, dynamic>?) ?? {};

    switch (type) {
      case 'youtube':
      case 'youtubecard':
      case 'video':
        return YouTubeCard(
          videoUrl: props['url'] ?? props['video_url'] ?? '',
          title: props['title'] as String?,
          transcripts: (props['transcripts'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
          followUpPrompts: (props['follow_up_prompts'] as List?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          onPromptTap: onPromptTap,
        );

      case 'math':
      case 'mathcard':
      case 'latex':
        return MathCard(
          latex: props['latex'] ?? props['equation'] ?? '',
          title: props['title'] as String?,
          steps: (props['steps'] as List?)?.map((e) => e.toString()).toList() ?? [],
        );

      case 'time':
      case 'timecard':
      case 'clock':
        return TimeCard(
          location: props['location'] ?? 'Current Location',
          timezone: props['timezone'] ?? 'UTC',
          utcOffset: props['utc_offset'] as String?,
          countryFlag: props['country_flag'] as String?,
        );

      case 'search':
      case 'searchresults':
      case 'search_results':
        return SearchResultsCard(
          query: props['query'] ?? '',
          results: (props['results'] as List?)
                  ?.map((e) => e as Map<String, dynamic>)
                  .toList() ??
              [],
        );

      case 'chart':
      case 'chartcard':
        final rawValues = props['values'] as List? ?? [];
        final values = rawValues.map((v) => (v as num).toDouble()).toList();
        final rawLabels = props['labels'] as List? ?? [];
        final labels = rawLabels.map((l) => l.toString()).toList();

        return ChartCard(
          title: props['title'] ?? 'Analytics Chart',
          chartType: props['chart_type'] ?? 'bar',
          labels: labels,
          values: values,
          unit: props['unit'] as String?,
        );

      case 'datatable':
      case 'table':
        final rawColumns = (props['columns'] as List?)?.map((c) => c.toString()).toList() ?? [];
        final rawRows = (props['rows'] as List?)
                ?.map((r) => (r as List).map((cell) => cell).toList())
                .toList() ??
            [];

        return DataTableCard(
          title: props['title'] ?? 'Data Records',
          columns: rawColumns,
          rows: rawRows,
        );

      case 'info':
      case 'infocard':
      case 'project':
      case 'projectcard':
        return InfoCard(
          title: props['title'] ?? 'Information',
          subtitle: props['subtitle'] as String?,
          status: props['status'] as String?,
          metrics: (props['metrics'] as Map<String, dynamic>?) ?? {},
          summary: props['summary'] as String?,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}
