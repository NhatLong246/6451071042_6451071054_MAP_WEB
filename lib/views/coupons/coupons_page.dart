import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/coupon_controller.dart';
import '../../data/models/coupon_model.dart';

class CouponsPage extends StatelessWidget {
  const CouponsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CouponController()..fetchCoupons(),
      child: const Scaffold(
        backgroundColor: Color(0xFFF8F9FD),
        body: _CouponsView(),
      ),
    );
  }
}

class _CouponsView extends StatelessWidget {
  const _CouponsView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CouponController>();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// --- TOP BAR ---
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quản Lý Mã Giảm Giá",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2B3674),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _showDialog(context),
                icon: const Icon(Icons.add_rounded),
                label: const Text("THÊM MÃ"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4318FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          /// --- SEARCH FIELD ---
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              onChanged: controller.search,
              decoration: const InputDecoration(
                hintText: "Tìm kiếm mã giảm giá...",
                prefixIcon: Icon(Icons.search, color: Color(0xFF4318FF)),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
          const SizedBox(height: 24),

          /// --- DATA TABLE AREA ---
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: controller.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: DataTable(
                            headingRowHeight: 56,
                            dataRowMaxHeight: 64,
                            columnSpacing: 24,
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF4F7FE),
                            ),
                            columns: const [
                              DataColumn(label: _TableLabel("SEQ")),
                              DataColumn(label: _TableLabel("COUPON")),
                              DataColumn(label: _TableLabel("DISCOUNT VALUE")),
                              DataColumn(label: _TableLabel("TYPE")),
                              DataColumn(label: _TableLabel("DESCRIPTION")),
                              DataColumn(label: _TableLabel("IS ACTIVE")),
                              DataColumn(label: _TableLabel("START DATE")),
                              DataColumn(label: _TableLabel("END DATE")),
                              DataColumn(label: _TableLabel("ACTION")),
                            ],
                            rows: controller.paginatedData.asMap().entries.map((
                              entry,
                            ) {
                              final index = entry.key;
                              final c = entry.value;
                              final seq =
                                  (controller.currentPage - 1) *
                                      controller.rowsPerPage +
                                  index +
                                  1;
                              return DataRow(
                                cells: [
                                  // SEQ
                                  DataCell(
                                    Text(
                                      "$seq",
                                      style: const TextStyle(
                                        color: Color(0xFFA3AED0),
                                      ),
                                    ),
                                  ),
                                  // COUPON
                                  DataCell(
                                    Text(
                                      c.code,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF2B3674),
                                      ),
                                    ),
                                  ),
                                  // DISCOUNT VALUE
                                  DataCell(
                                    Text(
                                      c.discountType == DiscountType.percentage
                                          ? "${c.discountValue}%"
                                          : "${c.discountValue.toStringAsFixed(0)} đ",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  // TYPE
                                  DataCell(
                                    Text(
                                      c.discountType == DiscountType.percentage
                                          ? "Percentage"
                                          : "Flat",
                                    ),
                                  ),
                                  // DESCRIPTION
                                  DataCell(
                                    SizedBox(
                                      width: 180,
                                      child: Text(
                                        c.description,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // IS ACTIVE
                                  DataCell(_StatusBadge(isActive: c.isActive)),
                                  // START DATE
                                  DataCell(
                                    Text(
                                      c.startDate != null
                                          ? "${c.startDate!.day}/${c.startDate!.month}/${c.startDate!.year}"
                                          : "-",
                                    ),
                                  ),
                                  // END DATE
                                  DataCell(
                                    Text(
                                      c.endDate != null
                                          ? "${c.endDate!.day}/${c.endDate!.month}/${c.endDate!.year}"
                                          : "-",
                                    ),
                                  ),
                                  // ACTION
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _CircularActionButton(
                                          icon: Icons.edit_rounded,
                                          color: Colors.blue,
                                          onPressed: () =>
                                              _showDialog(context, coupon: c),
                                        ),
                                        const SizedBox(width: 8),
                                        _CircularActionButton(
                                          icon: Icons.delete_outline_rounded,
                                          color: Colors.red,
                                          onPressed: () =>
                                              controller.delete(c.id),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, {CouponModel? coupon}) {
    showDialog(
      context: context,
      builder: (_) => _CouponDialog(coupon: coupon),
    );
  }
}

// ─────────────────────────── COUPON DIALOG ───────────────────────────────────

class _CouponDialog extends StatefulWidget {
  final CouponModel? coupon;
  const _CouponDialog({this.coupon});

  @override
  State<_CouponDialog> createState() => _CouponDialogState();
}

class _CouponDialogState extends State<_CouponDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _codeCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _valueCtrl;
  late final TextEditingController _limitCtrl;
  late DiscountType _type;
  late bool _isActive;
  late DateTime _startDate;
  late DateTime _endDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final c = widget.coupon;
    _codeCtrl = TextEditingController(text: c?.code ?? '');
    _descCtrl = TextEditingController(text: c?.description ?? '');
    _valueCtrl = TextEditingController(
        text: c?.discountValue == null ? '' : c!.discountValue.toStringAsFixed(
            c.discountType == DiscountType.flat ? 0 : 1));
    _limitCtrl = TextEditingController(
        text: c?.usageLimit == null ? '100' : '${c!.usageLimit}');
    _type = c?.discountType ?? DiscountType.percentage;
    _isActive = c?.isActive ?? true;
    _startDate = c?.startDate ?? DateTime.now();
    _endDate = c?.endDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _valueCtrl.dispose();
    _limitCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: isStart ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4318FF),
            onPrimary: Colors.white,
          ),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 7));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    final code = _codeCtrl.text.trim();
    final desc = _descCtrl.text.trim();
    final value = double.tryParse(_valueCtrl.text.trim()) ?? 0;
    final limit = int.tryParse(_limitCtrl.text.trim()) ?? 100;

    if (code.isEmpty || value <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ mã và giá trị giảm giá'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _saving = true);
    final controller = context.read<CouponController>();
    final model = CouponModel(
      id: widget.coupon?.id ?? '',
      code: code.toUpperCase(),
      description: desc,
      discountType: _type,
      discountValue: value,
      startDate: _startDate,
      endDate: _endDate,
      usageLimit: limit,
      usageCount: widget.coupon?.usageCount ?? 0,
      isActive: _isActive,
      createdAt: widget.coupon?.createdAt ?? DateTime.now(),
      updateAt: DateTime.now(),
    );

    if (widget.coupon == null) {
      await controller.add(model);
    } else {
      await controller.update(model);
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.coupon != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: 480,
        padding: const EdgeInsets.all(28),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Header ──
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4318FF).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.local_offer_rounded,
                        color: Color(0xFF4318FF), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEdit ? 'Chỉnh Sửa Mã Giảm Giá' : 'Thêm Mã Giảm Giá',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2B3674),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // ── Mã coupon ──
              _label('Mã coupon *'),
              const SizedBox(height: 6),
              _field(
                controller: _codeCtrl,
                hint: 'VD: VLX10, CEMENT50K...',
                icon: Icons.confirmation_number_outlined,
                textCapitalization: TextCapitalization.characters,
              ),
              const SizedBox(height: 16),

              // ── Mô tả ──
              _label('Mô tả'),
              const SizedBox(height: 6),
              _field(
                controller: _descCtrl,
                hint: 'Nhập mô tả điều kiện áp dụng...',
                icon: Icons.description_outlined,
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // ── Loại giảm giá & Giá trị ──
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Loại giảm giá'),
                        const SizedBox(height: 6),
                        _dropdownType(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Giá trị giảm *'),
                        const SizedBox(height: 6),
                        _field(
                          controller: _valueCtrl,
                          hint: _type == DiscountType.percentage
                              ? 'VD: 10'
                              : 'VD: 50000',
                          icon: _type == DiscountType.percentage
                              ? Icons.percent
                              : Icons.attach_money,
                          isNumber: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Ngày bắt đầu & kết thúc ──
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Ngày bắt đầu'),
                        const SizedBox(height: 6),
                        _datePicker(
                          date: _startDate,
                          onTap: () => _pickDate(true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('Ngày kết thúc'),
                        const SizedBox(height: 6),
                        _datePicker(
                          date: _endDate,
                          onTap: () => _pickDate(false),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Giới hạn sử dụng ──
              _label('Giới hạn lượt sử dụng'),
              const SizedBox(height: 6),
              _field(
                controller: _limitCtrl,
                hint: 'VD: 100',
                icon: Icons.group_outlined,
                isNumber: true,
              ),
              const SizedBox(height: 16),

              // ── Trạng thái ──
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F7FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: SwitchListTile(
                  title: const Text('Kích hoạt mã',
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    _isActive ? 'Mã đang hoạt động' : 'Mã đã tạm dừng',
                    style: TextStyle(
                        fontSize: 12,
                        color: _isActive ? Colors.green : Colors.grey),
                  ),
                  value: _isActive,
                  activeColor: const Color(0xFF4318FF),
                  onChanged: (v) => setState(() => _isActive = v),
                  secondary: Icon(
                    _isActive ? Icons.toggle_on_rounded : Icons.toggle_off_rounded,
                    color: _isActive
                        ? const Color(0xFF4318FF)
                        : Colors.grey,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Actions ──
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy',
                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 120,
                    height: 44,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4318FF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        elevation: 0,
                      ),
                      onPressed: _saving ? null : _save,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Text(isEdit ? 'CẬP NHẬT' : 'THÊM MÃ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
        text,
        style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2B3674)),
      );

  Widget _field({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isNumber = false,
    int maxLines = 1,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 18, color: Colors.blueGrey),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E5FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E5FF)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF4318FF), width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _dropdownType() {
    return DropdownButtonFormField<DiscountType>(
      value: _type,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.tune_rounded, size: 18, color: Colors.blueGrey),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E5FF)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E5FF)),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      items: const [
        DropdownMenuItem(
            value: DiscountType.percentage,
            child: Text('Phần trăm (%)')),
        DropdownMenuItem(
            value: DiscountType.flat,
            child: Text('Số tiền (đ)')),
      ],
      onChanged: (v) => setState(() => _type = v!),
    );
  }

  Widget _datePicker({required DateTime date, required VoidCallback onTap}) {
    final formatted =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFF),
          border: Border.all(color: const Color(0xFFE0E5FF)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 16, color: Color(0xFF4318FF)),
            const SizedBox(width: 8),
            Text(formatted,
                style: const TextStyle(fontSize: 14, color: Color(0xFF2B3674))),
          ],
        ),
      ),
    );
  }
}

// ──────────────────────────── HELPER WIDGETS ─────────────────────────────────

class _TableLabel extends StatelessWidget {
  final String label;

  const _TableLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFFA3AED0),
        fontWeight: FontWeight.bold,
        fontSize: 13,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isActive ? 'Hoạt động' : 'Tạm dừng',
        style: TextStyle(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _CircularActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  const _CircularActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(icon, color: color, size: 20),
        onPressed: onPressed,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        padding: EdgeInsets.zero,
      ),
    );
  }
}
