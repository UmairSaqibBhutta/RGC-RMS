import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/controllers/visit_controller.dart';
import 'package:leadmanagementsystem/extensions/string_extensions.dart';
import 'package:leadmanagementsystem/models/project_model.dart' show FollowUp;
import 'package:leadmanagementsystem/models/visit_report_model.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/follow_up_form.dart';

/// Detail page for a single visit report, backed by the
/// `vist-report-detail/:id` API.
class VisitReportDetailScreen extends StatefulWidget {
  final String visitId;

  const VisitReportDetailScreen({super.key, required this.visitId});

  @override
  State<VisitReportDetailScreen> createState() =>
      _VisitReportDetailScreenState();
}

class _VisitReportDetailScreenState extends State<VisitReportDetailScreen> {
  late final VisitController controller;

  @override
  void initState() {
    super.initState();
    controller =
        Get.isRegistered<VisitController>() ? Get.find() : Get.put(VisitController());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getVisitDetail(widget.visitId);
    });
  }

  CheckIn? _latestCheckIn(VisitData visit) {
    if (visit.checkIn == null || visit.checkIn!.isEmpty) return null;
    return visit.checkIn!.last;
  }

  bool _hasAnyCheckIn(VisitData visit) =>
      visit.checkIn != null && visit.checkIn!.isNotEmpty;

  bool _hasCheckedOut(VisitData visit) =>
      visit.checkOut?.time != null && visit.checkOut!.time!.isNotEmpty;

  double _degreeToRadian(double degree) => degree * pi / 180;

  double _calculateDistanceKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const double earthRadiusKm = 6371;

    final double dLat = _degreeToRadian(lat2 - lat1);
    final double dLon = _degreeToRadian(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreeToRadian(lat1)) *
            cos(_degreeToRadian(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  double _calculateTotalCoveredDistanceKm(VisitData visit) {
    final List<CheckIn> points = [
      ...(visit.checkIn ?? []).where((e) => e.lat != null && e.long != null),
      if (visit.checkOut?.lat != null && visit.checkOut?.long != null)
        visit.checkOut!,
    ];

    if (points.length < 2) return 0.0;

    double totalDistance = 0.0;
    for (int i = 0; i < points.length - 1; i++) {
      totalDistance += _calculateDistanceKm(
        lat1: double.parse(points[i].lat!),
        lon1: double.parse(points[i].long!),
        lat2: double.parse(points[i + 1].lat!),
        lon2: double.parse(points[i + 1].long!),
      );
    }

    return totalDistance;
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate.isEmpty) return '-';
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;
    return DateFormat('dd MMM yyyy, hh:mm a').format(parsed);
  }

  Future<void> _openInMaps(CheckIn? point) async {
    if (point?.lat == null || point?.long == null) return;
    final lat = double.tryParse(point!.lat!);
    final long = double.tryParse(point.long!);
    if (lat == null || long == null) return;
    await UrlLauncherHelper.openMap(latitude: lat, longitude: long);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: mAppbar("Visit Report Details"),
      body: GetBuilder<VisitController>(
        builder: (cont) {
          if (cont.isVisitDetailLoading) return pleaseWaitLoader();

          final visit = cont.visitDetail;

          if (visit == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 48, color: Colors.grey),
                    const SizedBox(height: 12),
                    const Text(
                      "Visit report not found",
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () =>
                          controller.getVisitDetail(widget.visitId),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: appColor),
                      child: const Text('Retry',
                          style: TextStyle(color: whiteColor)),
                    ),
                  ],
                ),
              ),
            );
          }

          final CheckIn? latestCheckIn = _latestCheckIn(visit);
          final bool hasAnyCheckIn = _hasAnyCheckIn(visit);
          final bool hasCheckedOut = _hasCheckedOut(visit);
          final double totalDistanceKm =
              _calculateTotalCoveredDistanceKm(visit);

          return RefreshIndicator(
            onRefresh: () => controller.getVisitDetail(widget.visitId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (visit.userDetail != null) _userCard(visit),
                  if (visit.userDetail != null) const SizedBox(height: 12),
                  _sectionCard(
                    title: "Site Information",
                    children: [
                      _row(Icons.location_city, "Site", visit.site),
                      _row(Icons.holiday_village, "Town / Phase",
                          visit.townPahse),
                      _row(Icons.apartment, "Block", visit.block),
                      _row(Icons.badge_outlined, "GCO", visit.gco),
                      _row(Icons.person_outline, "Key Person", visit.keyPN),
                      _row(Icons.phone_outlined, "Contact", visit.keyPC,
                          onTap: (visit.keyPC != null &&
                                  visit.keyPC!.isNotEmpty)
                              ? () =>
                                  UrlLauncherHelper.makePhoneCall(visit.keyPC!)
                              : null),
                      _row(Icons.architecture, "Architect", visit.architect),
                      _row(Icons.call_merge, "Call Result", visit.callResult),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _timeBox(
                          title: "Check In",
                          icon: Icons.login,
                          isDone: hasAnyCheckIn,
                          isClosed: hasCheckedOut,
                          time: latestCheckIn?.time,
                          onOpenMap: hasAnyCheckIn
                              ? () => _openInMaps(latestCheckIn)
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _timeBox(
                          title: "Check Out",
                          icon: Icons.logout,
                          isDone: hasCheckedOut,
                          isClosed: hasCheckedOut,
                          time: visit.checkOut?.time,
                          onOpenMap: hasCheckedOut
                              ? () => _openInMaps(visit.checkOut)
                              : null,
                        ),
                      ),
                    ],
                  ),
                  if (visit.checkIn != null && visit.checkIn!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _checkInHistory(visit.checkIn!),
                  ],
                  const SizedBox(height: 12),
                  _distanceBox(totalDistanceKm),
                  if (hasCheckedOut) ...[
                    const SizedBox(height: 12),
                    _closedBanner(),
                  ],
                  const SizedBox(height: 12),
                  _sectionCard(
                    title: "Record Info",
                    children: [
                      _row(Icons.calendar_today_outlined, "Created",
                          _formatDate(visit.createdAt)),
                      _row(Icons.update, "Last Updated",
                          _formatDate(visit.updatedAt)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildFollowUpsSection(visit),
                  const SizedBox(height: 12),
                  FollowUpForm(
                    isLoading: cont.followUpLoader,
                    onSubmit: (text, image) async {
                      final added = await cont.addVisitReportFollowUp(
                        visitReportId: widget.visitId,
                        text: text,
                        image: image,
                      );
                      if (added) {
                        await cont.getVisitDetail(widget.visitId);
                      }
                      return added;
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFollowUpsSection(VisitData visit) {
    final followUps = visit.followUp ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Follow Ups',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(
                  color: appColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${followUps.length}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (followUps.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE9EAEC)),
              ),
              child: const Text(
                'No follow ups yet.',
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            )
          else
            for (final followUp in followUps.reversed)
              _buildFollowUpTile(followUp),
        ],
      ),
    );
  }

  Widget _buildFollowUpTile(FollowUp followUp) {
    final name = followUp.user?.name;
    final hasName = name.isNotNullOrEmpty;
    final initial = hasName ? name!.substring(0, 1).toUpperCase() : '?';
    final createdAt = followUp.createdAt;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: appColor.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: appColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hasName ? name! : 'Unknown',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (createdAt != null)
                Text(
                  DateFormat('MMM d, h:mm a').format(createdAt),
                  style: const TextStyle(fontSize: 11, color: Colors.black45),
                ),
            ],
          ),
          if (followUp.text.isNotNullOrEmpty) ...[
            const SizedBox(height: 8),
            Text(
              followUp.text!,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
          ],
          if (followUp.image.isNotNullOrEmpty) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              // Same `baseUrl + <path>` convention used for chat images
              // (see chat_page.dart) and the project details follow-ups —
              // the API returns a bare filename here.
              child: CachedNetworkImage(
                imageUrl: baseUrl + followUp.image!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (_, __) => const SizedBox(
                  height: 150,
                  child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2)),
                ),
                errorWidget: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _userCard(VisitData visit) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: appColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: appColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: appColor,
            child: Icon(Icons.person, color: whiteColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visit.userDetail?.name ?? '-',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                if ((visit.userDetail?.role ?? '').isNotEmpty)
                  Text(
                    visit.userDetail!.role!,
                    style: const TextStyle(color: Colors.black54),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String title, String? value,
      {VoidCallback? onTap}) {
    final displayValue = (value != null && value.isNotEmpty) ? value : '-';

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: appColor),
            const SizedBox(width: 10),
            SizedBox(
              width: 110,
              child: Text(
                title,
                style: const TextStyle(
                    color: Colors.black54, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Text(
                displayValue,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: onTap != null ? appColor : Colors.black87,
                  decoration:
                      onTap != null ? TextDecoration.underline : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeBox({
    required String title,
    required IconData icon,
    required bool isDone,
    required bool isClosed,
    String? time,
    VoidCallback? onOpenMap,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDone ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDone ? Colors.green : Colors.grey.shade300,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: isDone ? Colors.green : Colors.grey),
          const SizedBox(height: 6),
          Text(title,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(
            isDone ? (time ?? '-') : 'Not Marked',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDone ? Colors.green.shade800 : Colors.black54,
            ),
          ),
          if (onOpenMap != null) ...[
            const SizedBox(height: 6),
            InkWell(
              onTap: onOpenMap,
              child: const Text(
                'Open in Maps',
                style: TextStyle(
                    fontSize: 11,
                    color: appColor,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _checkInHistory(List<CheckIn> checkIns) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Check In History (${checkIns.length})",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ...checkIns.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final hasCoords = item.lat != null && item.long != null;

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 11,
                    backgroundColor: appColor,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                          fontSize: 11,
                          color: whiteColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.time ?? "-",
                      style: const TextStyle(
                          fontSize: 13, color: Colors.black87),
                    ),
                  ),
                  if (hasCoords)
                    InkWell(
                      onTap: () => _openInMaps(item),
                      child: const Icon(Icons.map_outlined,
                          size: 18, color: appColor),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _distanceBox(double totalDistanceKm) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.directions_car, size: 18, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            "Distance Covered: ${totalDistanceKm.toStringAsFixed(2)} km",
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _closedBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 16, color: Colors.red),
          SizedBox(width: 6),
          Text(
            "Visit Closed",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
