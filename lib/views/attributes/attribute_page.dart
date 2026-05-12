import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/attribute_controller.dart';
import '../../data/services/attribute_service.dart';
import 'attribute_add_edit_page.dart';

class AttributesPage extends StatelessWidget {
  const AttributesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = AttributeService();
    return ChangeNotifierProvider(
      create: (_) => AttributeController(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF3F4F9), // Nền xám xanh nhẹ hiện đại
        body: Consumer<AttributeController>(
          builder: (context, controller, _) {
            return StreamBuilder(
              stream: service.getAll(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.indigo),
                  );
                }
                if (snapshot.hasData) {
                  controller.setData(snapshot.data!);
                }
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ---
                      const Text(
                      "Thuộc Tính Vật Liệu",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C24),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: TextField(
                                onChanged: controller.search,
                                decoration: InputDecoration(
                                  hintText: "Tìm kiếm theo tên hoặc giá trị...",
                                  prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: Colors.indigo,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AttributeFormPage(),
                              ),
                            ),
                            icon: const Icon(
                              Icons.add_rounded,
                              color: Colors.white,
                            ),
                            label: const Text("THÊM THUỘC TÍNH"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 20,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // --- TABLE CONTAINER ---
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: controller.paginatedData.isEmpty
                                ? SizedBox(
                                    width: double.infinity,
                                    height: 200,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.inbox_rounded,
                                            size: 48,
                                            color: Colors.grey.shade300),
                                        const SizedBox(height: 12),
                                        Text(
                                          'Không có thuộc tính nào',
                                          style: TextStyle(
                                              color: Colors.grey.shade400,
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                : Scrollbar(
                                    thumbVisibility: true,
                                    thickness: 6,
                                    child: SingleChildScrollView(
                                      // cuộn dọc
                                      child: SingleChildScrollView(
                                        // cuộn ngang
                                        scrollDirection: Axis.horizontal,
                                        child: ConstrainedBox(
                                          constraints: const BoxConstraints(
                                              minWidth: 900),
                                          child: DataTable(
                                headingRowColor: MaterialStateProperty.all(
                                  Colors.indigo.withOpacity(0.05),
                                ),
                                dataRowHeight: 75,
                                horizontalMargin: 24,
                                columnSpacing: 16,
                                columns: const [
                                  DataColumn(
                                    label: Text(
                                      "STT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "TÊN THUỘC TÍNH",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "GIÁ TRỊ",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "TRẠNG THÁI",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "CẬP NHẬT",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                  DataColumn(
                                    label: Text(
                                      "THAO TÁC",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    ),
                                  ),
                                ],
                                rows: List.generate(controller.paginatedData.length, (
                                  index,
                                ) {
                                  final item = controller.paginatedData[index];
                                  return DataRow(
                                    onSelectChanged: (_) {},
                                    cells: [
                                      DataCell(
                                        Text(
                                          "#${index + 1 + (controller.currentPage * controller.rowsPerPage)}",
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 160,
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        SizedBox(
                                          width: 320,
                                          child: Wrap(
                                            spacing: 6,
                                            runSpacing: 4,
                                            children: item.attributeValues
                                                .map(
                                                  (v) => Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 10,
                                                          vertical: 4,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.blueGrey
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                      border: Border.all(
                                                        color: Colors.blueGrey
                                                            .withOpacity(0.2),
                                                      ),
                                                    ),
                                                    child: Text(
                                                      v,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.blueGrey,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                      ),
                                      DataCell(
                                        _buildStatusBadge(item.isActive),
                                      ),
                                      DataCell(
                                        Text(
                                          item.updatedAt?.toString().substring(
                                                0,
                                                10,
                                              ) ??
                                              "-",
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          children: [
                                            _buildActionIcon(
                                              Icons.edit_note_rounded,
                                              Colors.blue,
                                              () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (_) =>
                                                        AttributeFormPage(
                                                          attribute: item,
                                                        ),
                                                  ),
                                                );
                                              },
                                            ),
                                            const SizedBox(width: 8),
                                            _buildActionIcon(
                                              Icons.delete_sweep_rounded,
                                              Colors.redAccent,
                                              () {
                                                _showDeleteDialog(
                                                  context,
                                                  service,
                                                  item.id,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              // --- PAGINATION ---
              _buildPagination(controller),
            ],
          ),
        );
      },
            );
          },
        ),
      ),
    );
  }

  // Giao diện Badge Trạng thái
  Widget _buildStatusBadge(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFE3F9E5) : const Color(0xFFFEEBEB),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isActive ? "Hoạt động" : "Vô hiệu",
            style: TextStyle(
              color: isActive ? Colors.green[800] : Colors.red[800],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // Nút hành động (Edit/Delete) với hiệu ứng Hover
  Widget _buildActionIcon(IconData icon, Color color, VoidCallback onPressed) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }

  // Thanh phân trang thiết kế lại
  Widget _buildPagination(AttributeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(controller.totalPages, (index) {
        bool isCurrent = controller.currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: InkWell(
            onTap: () => controller.currentPage = index,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isCurrent ? Colors.indigoAccent : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isCurrent ? Colors.indigoAccent : Colors.grey[300]!,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Colors.indigoAccent.withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Text(
                "${index + 1}",
                style: TextStyle(
                  color: isCurrent ? Colors.white : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    AttributeService service,
    String id,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 10),
            Text('Xác nhận xóa'),
          ],
        ),
        content: const Text(
          'Thuộc tính này sẽ bị xóa vĩnh viễn. Bạn có chắc chắn không?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('HỦY'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              await service.delete(id);
              Navigator.pop(context);
            },
            child: const Text('XÓA', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
