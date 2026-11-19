import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/constants/launchers_helper.dart';
import 'package:leadmanagementsystem/models/visitor_detail_model.dart';
import 'package:leadmanagementsystem/controllers/visitor_controller.dart';
import 'package:leadmanagementsystem/screens/visitors/add_visitor_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/responsive_body.dart';
import 'package:url_launcher/url_launcher.dart';

class VisitorDetailScreen extends StatelessWidget {
  final String visitorId;
  const VisitorDetailScreen({super.key, required this.visitorId});

  Future<void> _confirmDelete(VisitorController c, VisitorDetail v) async {
    final ok = await Get.dialog<bool>(AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Delete visitor?'),
      content: Text(
          'This will permanently remove ${v.personName.isEmpty ? 'this visitor' : v.personName} and the saved card image.'),
      actions: [
        TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel')),
        TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete')),
      ],
    ));
    if (ok == true && await c.deleteVisitor(v.id)) Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VisitorController>(builder: (c) {
      final visitor = c.byId(visitorId);
      if (visitor == null) {
        return Scaffold(
            appBar: mAppbar('Visitor Details'),
            body: const Center(child: Text('Visitor not found')));
      }
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: mAppbar('Visitor Details', action: [
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined, color: appColor),
            onPressed: () => Get.to(() => AddVisitorScreen(visitor: visitor)),
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: c.isSubmitting ? null : () => _confirmDelete(c, visitor),
          ),
        ]),
        body: SafeArea(
          child: LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 760;
            final info = _infoSections(visitor);
            final card = visitor.hasImage ? _cardImage(visitor) : null;
            return ResponsiveBody(
              maxWidth: 1000,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _header(visitor),
                  const SizedBox(height: 16),
                  if (wide && card != null)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: card),
                        const SizedBox(width: 16),
                        Expanded(child: Column(children: info)),
                      ],
                    )
                  else ...[
                    if (card != null) ...[card, const SizedBox(height: 16)],
                    ...info,
                  ],
                  if (visitor.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Added ${DateFormat('dd MMM yyyy, hh:mm a').format(visitor.createdAt!)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
      );
    });
  }

  List<Widget> _infoSections(VisitorDetail visitor) => [
        if (visitor.contacts.isNotEmpty)
          _section('Contact Numbers', [
            for (final n in visitor.contacts)
              _row(Icons.phone_outlined, n,
                  trailing: IconButton(
                    icon: const Icon(Icons.call, color: appColor),
                    onPressed: () => UrlLauncherHelper.makePhoneCall(n),
                  )),
          ]),
        if (visitor.email.isNotEmpty)
          _section('Email', [
            _row(Icons.mail_outline, visitor.email,
                trailing: IconButton(
                  icon: const Icon(Icons.send_outlined, color: appColor),
                  onPressed: () =>
                      launchUrl(Uri(scheme: 'mailto', path: visitor.email)),
                )),
          ]),
        if (visitor.officeAddress.isNotEmpty)
          _section('Office Address', [
            _row(Icons.location_on_outlined, visitor.officeAddress,
                trailing: IconButton(
                  icon: const Icon(Icons.map_outlined, color: appColor),
                  onPressed: () => launchUrl(
                      Uri.parse(
                          'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(visitor.officeAddress)}'),
                      mode: LaunchMode.externalApplication),
                )),
          ]),
      ];

  Widget _header(VisitorDetail visitor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00a569), Color(0xFF007a4e)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Text(
              visitor.personName.isNotEmpty
                  ? visitor.personName[0].toUpperCase()
                  : '?',
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(visitor.personName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(visitor.designation,
                    style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 8),
                Row(children: [
                  const Icon(Icons.business, size: 15, color: Colors.white),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(visitor.companyName,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cardImage(VisitorDetail visitor) {
    final url = baseUrl + visitor.image!;
    return GestureDetector(
      onTap: () => Get.to(() => Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: const Text('Visiting Card')),
            body: Center(
              child: InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Image.network(url),
              ),
            ),
          )),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
          color: Colors.white,
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                url,
                width: double.infinity,
                height: 220,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox(
                    height: 120,
                    child: Center(child: Icon(Icons.broken_image_outlined))),
              ),
            ),
            Positioned(
              right: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                    color: Colors.black54, shape: BoxShape.circle),
                child: const Icon(Icons.zoom_out_map,
                    size: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(),
              style: TextStyle(
                  fontSize: 11,
                  letterSpacing: .8,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 4),
          ...children,
        ],
      ),
    );
  }

  Widget _row(IconData icon, String text, {Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 10),
          Expanded(
            child: SelectableText(text, style: const TextStyle(fontSize: 15)),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
}
