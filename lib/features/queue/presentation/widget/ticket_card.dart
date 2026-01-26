import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/features/queue/data/models/user_ticket_model.dart';
import 'package:e_dut/features/queue/helper/constant/ticket_status.dart';
import 'package:flutter/material.dart';

class TicketCard extends StatelessWidget {
  final UserTicketModel ticket;
  const TicketCard({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    final status = TicketStatus.fromInt(ticket.ticketStatus);
    return Container(
      decoration: BoxDecoration(
        color: context.theme.lightGrey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: IntrinsicHeight(
          child: Row(
            spacing: 16,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Số thứ tự",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: context.theme.grey,
                      fontSize: FontSizes.small + 1,
                      height: 1.5,
                    ),
                  ),
                  Text(
                    ticket.noTicket.toString(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color:
                          status.isFinished
                              ? context.theme.grey
                              : context.theme.primaryColor,
                      fontSize: FontSizes.large * 3,
                      height: 1.1,
                    ),
                  ),
                  Text(
                    status.isProcessing
                        ? "Đến lượt bạn"
                        : status.isFinished
                        ? 'Đã hết lượt'
                        : "Còn ${ticket.countBeforeMe} lượt đợi",
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: context.theme.grey,
                      fontSize: FontSizes.small + 1,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
              const VerticalDivider(
                color: Color(0xFFECECEC),
                thickness: 1,
                width: 1,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Quầy ${ticket.noCounter}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF263238),
                        fontSize: FontSizes.medium,
                      ),
                    ),
                    Text(
                      ticket.serviceName.trim(),
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: context.theme.grey,
                        fontSize: FontSizes.small,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
