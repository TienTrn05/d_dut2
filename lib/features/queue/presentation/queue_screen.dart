import 'package:auto_route/auto_route.dart';
import 'package:e_dut/common/extensions/custom_theme_extension.dart';
import 'package:e_dut/common/extensions/font_sizes.dart';
import 'package:e_dut/common/utils/getit_utils.dart';
import 'package:e_dut/common/widgets/appbar/custom_appbar.dart';
import 'package:e_dut/common/widgets/snackbar/container_snackbar.dart';
import 'package:e_dut/core/bloc/notification_settings/notification_settings_bloc.dart';
import 'package:e_dut/features/auth/bloc/auth_bloc.dart';
import 'package:e_dut/features/auth/presentation/unauthorized_page.dart';
import 'package:e_dut/features/queue/bloc/queue_bloc.dart';
import 'package:e_dut/features/queue/domain/repository/queue_repo.dart';
import 'package:e_dut/features/queue/helper/constant/ticket_status.dart';
import 'package:e_dut/features/queue/presentation/widget/loading/counter_loading.dart';
import 'package:e_dut/features/queue/presentation/widget/loading/ticket_loading.dart';
import 'package:e_dut/features/queue/presentation/widget/queue_info_card.dart';
import 'package:e_dut/features/queue/presentation/widget/ticket_card.dart';
import 'package:e_dut/gen/assets.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';

@RoutePage()
class QueueScreen extends StatefulWidget {
  const QueueScreen({super.key});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  String getStudentId(String email) {
    if (email.contains('@')) {
      return email.split('@').first;
    }
    return email;
  }

  Widget _buildSwitchTile(
    BuildContext context,
    String title,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.all(0),
      title: Text(
        title,
        style: TextStyle(
          fontSize: FontSizes.medium,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: Switch(
        padding: EdgeInsets.all(0),
        activeColor: Colors.white,
        activeTrackColor: context.theme.primaryColor,
        inactiveThumbColor: context.theme.grey,
        inactiveTrackColor: context.theme.lightGrey,
        value: value,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUserTicketsSection(BuildContext context, QueueState state) {
    return QueueInfoCard(
      title: 'Vé của bạn hôm nay',
      child:
          state.ticketsStatus == QueueStatus.loading
              ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: TicketLoading(),
                ),
              )
              : state.userTickets.isEmpty
              ? Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  'Bạn chưa có vé nào hôm nay',
                  style: TextStyle(
                    color: context.theme.grey,
                    fontSize: FontSizes.medium,
                  ),
                ),
              )
              : Column(
                spacing: 16,
                children:
                    state.userTickets
                        .map((ticket) => TicketCard(ticket: ticket))
                        .toList(),
              ),
    );
  }

  List<Widget> _buildCounterQueues(BuildContext context, QueueState state) {
    if (state.countersStatus == QueueStatus.loading) {
      return [CounterLoading()];
    }

    if (state.counterQueues.isEmpty) {
      return [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 4,
          children: [
            Icon(
              FontAwesome.exclamation_circle,
              size: 16,
              color: context.theme.grey,
            ),
            Text(
              "Các quầy chưa hoạt động, vui lòng quay lại sau.",
              style: TextStyle(
                fontWeight: FontWeight.normal,
                color: context.theme.grey,
                fontSize: FontSizes.small + 1,
              ),
            ),
          ],
        ),
      ];
    }

    return state.counterQueues.map((counter) {
      final currentTicket =
          counter.queueNoTickets.isNotEmpty
              ? counter.queueNoTickets.first
              : null;

      return QueueInfoCard(
        title: 'Quầy ${counter.noCounter}',
        counter: counter,
        child: Column(
          spacing: 16,
          children: [
            // Current serving ticket
            _buildCurrentTicket(context, currentTicket),

            // Waiting tickets
            if (counter.queueNoTickets.skip(1).toList().isNotEmpty)
              _buildWaitingTickets(
                context,
                counter.queueNoTickets.skip(1).toList(),
              ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildCurrentTicket(BuildContext context, dynamic currentTicket) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          currentTicket != null
              ? currentTicket.ticketStatus == TicketStatus.processing
                  ? "Đang phục vụ"
                  : "Số tiếp theo"
              : "Quầy đang trống",
          style: TextStyle(
            fontWeight: FontWeight.normal,
            color: context.theme.grey,
            fontSize: FontSizes.small + 1,
            height: 1.5,
          ),
        ),
        if (currentTicket != null)
          Text(
            '${currentTicket.noTicket}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: context.theme.primaryColor,
              fontSize: FontSizes.large * 3,
              height: 1.1,
            ),
          ),
      ],
    );
  }

  Widget _buildWaitingTickets(
    BuildContext context,
    List<dynamic> waitingTickets,
  ) {
    if (waitingTickets.isEmpty) return const SizedBox.shrink();

    return Column(
      spacing: 8,
      children:
          waitingTickets.map((ticket) {
            return Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: context.theme.lightGrey,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16),
              child: Text(
                ticket.noTicket.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: FontSizes.medium,
                  fontWeight: FontWeight.bold,
                  color: Color(0XFF263238),
                ),
              ),
            );
          }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthUserAuthenticated) {
          return UnauthorizedPage(title: "Lấy số tổ 1 cửa");
        }
        return BlocProvider(
          create:
              (context) => QueueBloc(getIt<QueueRepository>())..add(
                LoadQueueDataEvent(
                  noGuest: getStudentId(authState.userData.userPrincipalName),
                ),
              ),

          child: BlocBuilder<QueueBloc, QueueState>(
            builder: (context, state) {
              return Scaffold(
                appBar: CustomAppbar(
                  label: "Lấy số tổ 1 cửa",
                  showNotificationButton: false,
                  child: Builder(
                    builder: (context) {
                      return IconButton(
                        icon: SvgPicture.asset(
                          Assets.icons.svg.solarSettingsBroken,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openEndDrawer();
                        },
                      );
                    },
                  ),
                ),
                endDrawer: BlocBuilder<
                  NotificationSettingsBloc,
                  NotificationSettingsState
                >(
                  builder: (context, settingState) {
                    final options = remainTurns;
                    final selectedIndex = options.indexOf(
                      settingState.remainTurn,
                    );
                    return Drawer(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          bottomLeft: Radius.circular(16),
                        ),
                      ),
                      backgroundColor: Colors.white,
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    Assets.icons.svg.solarBellBold,
                                    colorFilter: ColorFilter.mode(
                                      context.theme.primaryColor ?? Colors.blue,
                                      BlendMode.srcIn,
                                    ),
                                    width: 24,
                                    height: 24,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Thông báo lượt đợi",
                                    style: TextStyle(
                                      fontSize: FontSizes.large,
                                      fontWeight: FontWeight.bold,
                                      color: context.theme.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                              Divider(color: context.theme.primaryColor),
                              _buildSwitchTile(
                                context,
                                "Bật thông báo sắp đến lượt",
                                settingState.queueEnabled,
                                (value) {
                                  context.read<NotificationSettingsBloc>().add(
                                    ToggleQueueNotification(isEnabled: value),
                                  );
                                },
                              ),

                              Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                spacing: 4,
                                children: [
                                  Text(
                                    'Báo khi còn',
                                    style: TextStyle(
                                      fontSize: FontSizes.medium,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  IgnorePointer(
                                    ignoring: !settingState.queueEnabled,
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        final itemWidth =
                                            (constraints.maxWidth - 8) /
                                            options.length;

                                        return Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color:
                                                settingState.queueEnabled
                                                    ? context.theme.lightBlue
                                                    : context.theme.lightGrey,
                                            borderRadius: BorderRadius.circular(
                                              999,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              AnimatedPositioned(
                                                duration: const Duration(
                                                  milliseconds: 250,
                                                ),
                                                curve: Curves.easeInOut,
                                                left: selectedIndex * itemWidth,
                                                top: 0,
                                                bottom: 0,
                                                width: itemWidth,
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        settingState
                                                                .queueEnabled
                                                            ? context
                                                                .theme
                                                                .primaryColor
                                                            : context
                                                                .theme
                                                                .grey,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          999,
                                                        ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.1),
                                                        blurRadius: 4,
                                                        offset: const Offset(
                                                          0,
                                                          2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),

                                              Row(
                                                children: List.generate(options.length, (
                                                  index,
                                                ) {
                                                  final isSelected =
                                                      selectedIndex == index;
                                                  final value = options[index];
                                                  return Expanded(
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        context
                                                            .read<
                                                              NotificationSettingsBloc
                                                            >()
                                                            .add(
                                                              RemainTurnsChanged(
                                                                token:
                                                                    authState
                                                                        .accessToken,
                                                                remainTurn:
                                                                    value,
                                                              ),
                                                            );
                                                      },
                                                      child: Container(
                                                        padding:
                                                            const EdgeInsets.symmetric(
                                                              horizontal: 8,
                                                              vertical: 10,
                                                            ),
                                                        color:
                                                            Colors.transparent,
                                                        child: Center(
                                                          child: AnimatedDefaultTextStyle(
                                                            duration:
                                                                const Duration(
                                                                  milliseconds:
                                                                      200,
                                                                ),
                                                            style: TextStyle(
                                                              fontSize:
                                                                  FontSizes
                                                                      .medium,
                                                              height: 1.2,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  isSelected
                                                                      ? Colors
                                                                          .white
                                                                      : Colors
                                                                          .black87,
                                                            ),
                                                            child: Text(
                                                              '${options[index].toString()} lượt',
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              Expanded(child: SizedBox.shrink()),
                              if (settingState.errorMessage != null)
                                ContainerSnackbar(
                                  title: "Cập nhật thất bại",
                                  message:
                                      settingState.errorMessage ??
                                      "Có lỗi xảy ra",
                                  alertType: AlertType.error,
                                  onClose: () {
                                    context
                                        .read<NotificationSettingsBloc>()
                                        .add(ClearErrorMessage());
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
                backgroundColor: context.theme.lightGrey,
                body: RefreshIndicator(
                  color: Theme.of(context).primaryColor,
                  backgroundColor: Colors.white,
                  onRefresh: () async {
                    context.read<QueueBloc>().add(
                      LoadQueueDataEvent(
                        noGuest: getStudentId(
                          authState.userData.userPrincipalName,
                        ),
                      ),
                    );
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      spacing: 16,
                      children: [
                        _buildUserTicketsSection(context, state),

                        ..._buildCounterQueues(context, state),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
