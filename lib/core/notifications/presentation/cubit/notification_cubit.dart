import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/app_notification.dart';

class NotificationState extends Equatable {
  final List<AppNotification> notifications;
  final bool hasUnread;

  const NotificationState({
    this.notifications = const [],
    this.hasUnread = false,
  });

  @override
  List<Object?> get props => [notifications, hasUnread];
}

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(const NotificationState());

  void addNotification(AppNotification notification) {
    // Check if we already have a low stock notification for this product to avoid spam
    if (notification.type == NotificationType.lowStock) {
      final exists = state.notifications.any((n) => 
        n.type == NotificationType.lowStock && 
        n.productId == notification.productId && 
        !n.isRead
      );
      if (exists) return;
    }

    final updatedList = [notification, ...state.notifications];
    emit(NotificationState(
      notifications: updatedList,
      hasUnread: true,
    ));
  }

  void markAsRead(String id) {
    final updatedList = state.notifications.map((n) {
      if (n.id == id) return n.copyWith(isRead: true);
      return n;
    }).toList();
    
    emit(NotificationState(
      notifications: updatedList,
      hasUnread: updatedList.any((n) => !n.isRead),
    ));
  }

  void markAllAsRead() {
    final updatedList = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    emit(NotificationState(
      notifications: updatedList,
      hasUnread: false,
    ));
  }

  void clearAll() {
    emit(const NotificationState(notifications: [], hasUnread: false));
  }
}
