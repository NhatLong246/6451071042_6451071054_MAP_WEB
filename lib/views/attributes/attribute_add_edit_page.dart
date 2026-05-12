import 'package:flutter/material.dart';
import '../../data/models/attribute_model.dart';
import '../../data/services/attribute_service.dart';

class AttributeFormPage extends StatefulWidget {
  final AttributeModel? attribute;

  const AttributeFormPage({super.key, this.attribute});

  @override
  State<AttributeFormPage> createState() => _AttributeFormPageState();
}

class _AttributeFormPageState extends State<AttributeFormPage> {
  final _nameCtrl = TextEditingController();
  final _tagInputCtrl = TextEditingController();
  final _service = AttributeService();

  bool _isActive = true;
  bool _isSearchable = false;
  bool _isFilterable = true;
  bool _isColorAttribute = false;
  bool _saving = false;

  // Danh sách giá trị thuộc tính (thêm/xóa từng tag)
  final List<String> _values = [];

  @override
  void initState() {
    super.initState();
    if (widget.attribute != null) {
      final a = widget.attribute!;
      _nameCtrl.text = a.name;
      _values.addAll(a.attributeValues);
      _isActive = a.isActive;
      _isSearchable = a.isSearchable;
      _isFilterable = a.isFilterable;
      _isColorAttribute = a.isColorAttribute;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _tagInputCtrl.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagInputCtrl.text.trim();
    if (tag.isEmpty) return;
    if (_values.contains(tag)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giá trị này đã tồn tại'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() {
      _values.add(tag);
      _tagInputCtrl.clear();
    });
  }

  void _removeTag(String tag) => setState(() => _values.remove(tag));

  Future<void> _save() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập tên thuộc tính'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (_values.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất một giá trị'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final model = AttributeModel(
      id: widget.attribute?.id ?? '',
      name: _nameCtrl.text.trim(),
      attributeValues: List.from(_values),
      isActive: _isActive,
      isSearchable: _isSearchable,
      isFilterable: _isFilterable,
      isColorAttribute: _isColorAttribute,
    );

    if (widget.attribute == null) {
      await _service.create(model);
    } else {
      await _service.update(model);
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.attribute == null
              ? 'Đã thêm thuộc tính thành công'
              : 'Đã cập nhật thuộc tính thành công'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.attribute != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Colors.indigo, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isEdit ? 'Chỉnh Sửa Thuộc Tính' : 'Thêm Thuộc Tính Mới',
          style: const TextStyle(
            color: Color(0xFF1A1C24),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card: Thông tin cơ bản ──────────────────────────────────
            _card(
              title: 'Thông tin thuộc tính',
              icon: Icons.label_outline_rounded,
              children: [
                _sectionLabel('Tên thuộc tính *'),
                const SizedBox(height: 8),
                _textField(
                  controller: _nameCtrl,
                  hint: 'VD: Loại vật liệu, Màu sắc, Kích thước...',
                  icon: Icons.drive_file_rename_outline_rounded,
                ),
                const SizedBox(height: 24),

                // ── Values tag input ──────────────────────────────────
                _sectionLabel('Danh sách giá trị'),
                const SizedBox(height: 4),
                Text(
                  'Nhập từng giá trị rồi nhấn nút + hoặc Enter để thêm',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _textField(
                        controller: _tagInputCtrl,
                        hint: 'VD: Xi măng, PCB40, 60x60...',
                        icon: Icons.add_circle_outline_rounded,
                        onSubmitted: (_) => _addTag(),
                      ),
                    ),
                    const SizedBox(width: 10),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _addTag,
                        child: const Icon(Icons.add_rounded, size: 22),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _values.isEmpty
                    ? Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          border: Border.all(
                              color: Colors.grey.shade200,
                              style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Center(
                          child: Text(
                            'Chưa có giá trị nào. Hãy thêm giá trị ở trên.',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ),
                      )
                    : Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.indigo.withOpacity(0.03),
                          border:
                              Border.all(color: Colors.indigo.withOpacity(0.15)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _values.map((v) => _buildValueChip(v)).toList(),
                        ),
                      ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Card: Cài đặt ─────────────────────────────────────────
            _card(
              title: 'Cài đặt thuộc tính',
              icon: Icons.tune_rounded,
              children: [
                _switchRow(
                  icon: Icons.visibility_rounded,
                  iconColor: Colors.green,
                  title: 'Kích hoạt',
                  subtitle: 'Thuộc tính được hiển thị trên hệ thống',
                  value: _isActive,
                  onChanged: (v) => setState(() => _isActive = v),
                ),
                _divider(),
                _switchRow(
                  icon: Icons.search_rounded,
                  iconColor: Colors.blue,
                  title: 'Cho phép tìm kiếm',
                  subtitle: 'Khách hàng có thể tìm theo giá trị thuộc tính này',
                  value: _isSearchable,
                  onChanged: (v) => setState(() => _isSearchable = v),
                ),
                _divider(),
                _switchRow(
                  icon: Icons.filter_list_rounded,
                  iconColor: Colors.orange,
                  title: 'Cho phép lọc sản phẩm',
                  subtitle: 'Hiển thị dưới dạng bộ lọc trong danh mục',
                  value: _isFilterable,
                  onChanged: (v) => setState(() => _isFilterable = v),
                ),
                _divider(),
                _switchRow(
                  icon: Icons.color_lens_rounded,
                  iconColor: Colors.purple,
                  title: 'Thuộc tính màu sắc',
                  subtitle: 'Hiển thị dưới dạng ô màu thay vì danh sách',
                  value: _isColorAttribute,
                  onChanged: (v) => setState(() => _isColorAttribute = v),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // ── Nút lưu ──────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.indigo,
                      side: const BorderSide(color: Colors.indigo),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Hủy bỏ',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _saving ? null : _save,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : Icon(
                            isEdit
                                ? Icons.save_rounded
                                : Icons.add_circle_rounded,
                            size: 20),
                    label: Text(isEdit ? 'Cập nhật thuộc tính' : 'Thêm thuộc tính',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueChip(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  color: Colors.indigo,
                  fontWeight: FontWeight.w500)),
          const SizedBox(width: 6),
          InkWell(
            onTap: () => _removeTag(value),
            borderRadius: BorderRadius.circular(10),
            child: const Icon(Icons.close_rounded,
                size: 15, color: Colors.indigo),
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ──────────────────────────────────────────────────────

  Widget _card({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: Colors.indigo, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1A1C24),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF4A4D6B)),
      );

  Widget _textField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    void Function(String)? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
        prefixIcon: Icon(icon, size: 18, color: Colors.indigo.withOpacity(0.6)),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo.withOpacity(0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.indigo.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.indigo, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  Widget _switchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.indigo,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Divider(
      color: Colors.grey.shade100, thickness: 1, height: 20);
}
