import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:leadmanagementsystem/constants/constants.dart';
import 'package:leadmanagementsystem/controllers/visitor_controller.dart';
import 'package:leadmanagementsystem/models/visitor_detail_model.dart';
import 'package:leadmanagementsystem/screens/visitors/add_visitor_screen.dart';
import 'package:leadmanagementsystem/screens/visitors/visitor_detail_screen.dart';
import 'package:leadmanagementsystem/widgets/custom_widgets.dart';
import 'package:leadmanagementsystem/widgets/responsive_body.dart';

/// Visitor directory — available to every user role.
class VisitorListScreen extends StatefulWidget {
  const VisitorListScreen({super.key});

  @override
  State<VisitorListScreen> createState() => _VisitorListScreenState();
}

class _VisitorListScreenState extends State<VisitorListScreen> {
  late final VisitorController controller;
  final _searchCont = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = Get.put(VisitorController());
    WidgetsBinding.instance
        .addPostFrameCallback((_) => controller.getVisitors());
  }

  @override
  void dispose() {
    _searchCont.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: mAppbar('Visitor Details'),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: appColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Visitor'),
        onPressed: () => Get.to(() => const AddVisitorScreen()),
      ),
      body: ResponsiveBody(
        maxWidth: 1200,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchCont,
                onChanged: controller.search,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Search company, person or number',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _searchCont,
                    builder: (_, v, __) => v.text.isEmpty
                        ? const SizedBox.shrink()
                        : IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () {
                              _searchCont.clear();
                              controller.search('');
                            },
                          ),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.zero,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: appColor, width: 1.5),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GetBuilder<VisitorController>(builder: (c) {
                if (c.isListLoading) return pleaseWaitLoader();
                final items = c.visitors;
                return RefreshIndicator(
                  color: appColor,
                  onRefresh: c.getVisitors,
                  child: items.isEmpty
                      ? _empty(c.searchQuery.isNotEmpty)
                      : GridView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                          // 1 column on phones, 2-3 on tablets / landscape.
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 520,
                            mainAxisExtent: 104,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 10,
                          ),
                          itemCount: items.length,
                          itemBuilder: (_, i) =>
                              _VisitorCard(visitor: items[i]),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _empty(bool searching) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: Get.height * .16),
        Icon(searching ? Icons.search_off : Icons.contact_page_outlined,
            size: 72, color: Colors.grey.shade400),
        const SizedBox(height: 12),
        Center(
          child: Text(
            searching ? 'No visitors match your search' : 'No visitors yet',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            searching
                ? 'Try a different keyword'
                : 'Tap “Add Visitor” to save a business card',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ),
      ],
    );
  }
}

class _VisitorCard extends StatelessWidget {
  final VisitorDetail visitor;
  const _VisitorCard({required this.visitor});

  @override
  Widget build(BuildContext context) {
    final initial = visitor.personName.isNotEmpty
        ? visitor.personName[0].toUpperCase()
        : '?';
    final hasCard = visitor.hasImage;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Get.to(() => VisitorDetailScreen(visitorId: visitor.id)),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB)),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00a569), Color(0xFF00c27a)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(initial,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(visitor.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      [visitor.personName, visitor.designation]
                          .where((e) => e.isNotEmpty)
                          .join(' • '),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                    if (visitor.contacts.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Row(children: [
                        const Icon(Icons.phone_outlined,
                            size: 14, color: appColor),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            visitor.contacts.first +
                                (visitor.contacts.length > 1
                                    ? '  +${visitor.contacts.length - 1}'
                                    : ''),
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13),
                          ),
                        ),
                      ]),
                    ],
                  ],
                ),
              ),
              if (hasCard)
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      baseUrl + visitor.image!,
                      width: 56,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.badge_outlined, color: Colors.grey),
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
