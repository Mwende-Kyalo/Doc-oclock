// ...existing code...
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/sign_in_screen.dart';
import '../screens/auth/sign_up_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/entry_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/doctor_sign_in_supabase.dart';
import '../screens/patient/book_appointment_screen.dart';
import '../screens/patient/book_appointment_detail_screen.dart';
import '../screens/patient/appointments_list_screen.dart';
import '../screens/patient/appointment_detail_screen.dart';
import '../screens/patient/ehr_view_screen.dart';
import '../screens/patient/messages_screen.dart';
import '../screens/patient/chat_screen.dart';
import '../screens/patient/order_prescriptions_screen.dart';
import '../screens/patient/payment_screen.dart';
import '../screens/patient/settings_screen.dart';
import '../screens/patient/medicine_info_screen.dart';
import '../screens/patient/ratings_reviews_screen.dart';
import '../screens/doctor/doctor_dashboard_screen.dart';
import '../screens/doctor/doctor_messages_screen.dart';
import '../screens/doctor/doctor_chat_screen.dart';
import '../screens/doctor/doctor_ehr_screen.dart';
import '../screens/doctor/calendar_screen.dart';
import '../screens/doctor/patient_details_screen.dart';
import '../screens/doctor/add_ehr_screen.dart';
import '../screens/doctor/doctor_settings_screen.dart';
import '../screens/doctor/appointment_detail_screen.dart';
import '../screens/doctor/doctor_appointments_screen.dart';
import '../screens/doctor/doctor_payment_screen.dart';
import '../screens/patient/history_screen.dart';
import '../screens/doctor/doctor_history_screen.dart';
import '../screens/patient/rate_doctor_screen.dart';
import '../screens/patient/doctor_reviews_screen.dart';
import '../screens/doctor/doctor_reviews_view_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/entry',
    redirect: (context, state) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final isAuthenticated = authProvider.isAuthenticated;
      final isAuthRoute = state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/sign-up' ||
          state.matchedLocation == '/doctor-sign-in' ||
          state.matchedLocation == '/entry' ||
          state.matchedLocation == '/otp';

      if (!isAuthenticated && !isAuthRoute) {
        return '/sign-up';
      }

      if (isAuthenticated && isAuthRoute) {
        final user = authProvider.user;
        if (user?.role == UserRole.doctor) {
          return '/doctor/dashboard';
        } else {
          return '/patient/book-appointment';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/entry',
        builder: (context, state) => const EntryScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/entry',
        builder: (context, state) => const EntryScreen(),
      ),
      GoRoute(
        path: '/doctor-sign-in',
        builder: (context, state) => const DoctorSignInScreen(),
      ),
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/sign-up',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) => const OtpScreen(),
      ),
      // Patient routes
      GoRoute(
        path: '/patient/book-appointment',
        builder: (context, state) => const BookAppointmentScreen(),
      ),
      GoRoute(
        path: '/patient/book-appointment-detail',
        builder: (context, state) {
          final doctorId = state.uri.queryParameters['doctorId'] ?? '';
          final doctorName = state.uri.queryParameters['doctorName'] ?? '';
          final availabilityId = state.uri.queryParameters['availabilityId'] ?? '';
          final date = state.uri.queryParameters['date'] ?? '';
          final startTime = state.uri.queryParameters['startTime'] ?? '';
          final endTime = state.uri.queryParameters['endTime'] ?? '';
          return BookAppointmentDetailScreen(
            doctorId: doctorId,
            doctorName: Uri.decodeComponent(doctorName),
            availabilityId: availabilityId,
            date: date,
            startTime: Uri.decodeComponent(startTime),
            endTime: Uri.decodeComponent(endTime),
          );
        },
      ),
      GoRoute(
        path: '/patient/appointments',
        builder: (context, state) => const AppointmentsListScreen(),
      ),
      GoRoute(
        path: '/patient/appointment/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AppointmentDetailScreen(appointmentId: id);
        },
      ),
      GoRoute(
        path: '/patient/ehr',
        builder: (context, state) => const EhrViewScreen(),
      ),
      GoRoute(
        path: '/patient/messages',
        builder: (context, state) => const MessagesScreen(),
      ),
      GoRoute(
        path: '/patient/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final doctorName =
              state.uri.queryParameters['doctorName'] ?? 'Doctor';
          final doctorId = state.uri.queryParameters['doctorId'] ?? '';
          return ChatScreen(
            chatId: chatId,
            doctorName: Uri.decodeComponent(doctorName),
            doctorId: doctorId,
          );
        },
      ),
      GoRoute(
        path: '/patient/prescriptions',
        builder: (context, state) => const OrderPrescriptionsScreen(),
      ),
      GoRoute(
        path: '/patient/medicine-info',
        builder: (context, state) => const MedicineInfoScreen(),
      ),
      GoRoute(
        path: '/patient/payment',
        builder: (context, state) {
          final appointmentId = state.uri.queryParameters['appointmentId'];
          return PaymentScreen(appointmentId: appointmentId);
        },
      ),
      GoRoute(
        path: '/patient/history',
        builder: (context, state) => const PatientHistoryScreen(),
      ),
      GoRoute(
        path: '/patient/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/patient/rate-doctor',
        builder: (context, state) {
          final doctorId = state.uri.queryParameters['doctorId'] ?? '';
          final doctorName =
              state.uri.queryParameters['doctorName'] ?? 'Doctor';
          final appointmentId = state.uri.queryParameters['appointmentId'];
          return RateDoctorScreen(
            doctorId: doctorId,
            doctorName: Uri.decodeComponent(doctorName),
            appointmentId: appointmentId,
          );
        },
      ),
      GoRoute(
        path: '/patient/ratings-reviews',
        builder: (context, state) => const RatingsReviewsScreen(),
      ),
      GoRoute(
        path: '/patient/reviews/:doctorId',
        builder: (context, state) {
          final doctorId = state.pathParameters['doctorId']!;
          final doctorName =
              state.uri.queryParameters['doctorName'] ?? 'Doctor';
          return DoctorReviewsScreen(
            doctorId: doctorId,
            doctorName: Uri.decodeComponent(doctorName),
          );
        },
      ),
      // Doctor routes
      GoRoute(
        path: '/doctor/dashboard',
        builder: (context, state) => const DoctorDashboardScreen(),
      ),
      GoRoute(
        path: '/doctor/appointments',
        builder: (context, state) => const DoctorAppointmentsScreen(),
      ),
      GoRoute(
        path: '/doctor/messages',
        builder: (context, state) => const DoctorMessagesScreen(),
      ),
      GoRoute(
        path: '/doctor/chat/:chatId',
        builder: (context, state) {
          final chatId = state.pathParameters['chatId']!;
          final patientName =
              state.uri.queryParameters['patientName'] ?? 'Patient';
          final patientId = state.uri.queryParameters['patientId'] ?? '';
          return DoctorChatScreen(
            chatId: chatId,
            patientName: Uri.decodeComponent(patientName),
            patientId: patientId,
          );
        },
      ),
      GoRoute(
        path: '/doctor/ehr',
        builder: (context, state) => const DoctorEhrScreen(),
      ),
      GoRoute(
        path: '/doctor/patient/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final patientName = state.uri.queryParameters['patientName'];
          return PatientDetailsScreen(
            patientId: id,
            patientName: patientName,
          );
        },
      ),
      GoRoute(
        path: '/doctor/add-ehr',
        builder: (context, state) {
          final patientId = state.uri.queryParameters['patientId'] ?? '';
          final patientName = state.uri.queryParameters['patientName'] ?? '';
          final type = state.uri.queryParameters['type'];
          final ehrId = state.uri.queryParameters['ehrId'];
          return AddEhrScreen(
            patientId: patientId,
            patientName: Uri.decodeComponent(patientName),
            type: type,
            ehrId: ehrId,
          );
        },
      ),
      GoRoute(
        path: '/doctor/calendar',
        builder: (context, state) => const CalendarScreen(),
      ),
      GoRoute(
        path: '/doctor/payments',
        builder: (context, state) => const DoctorPaymentScreen(),
      ),
      GoRoute(
        path: '/doctor/history',
        builder: (context, state) => const DoctorHistoryScreen(),
      ),
      GoRoute(
        path: '/doctor/settings',
        builder: (context, state) => const DoctorSettingsScreen(),
      ),
      GoRoute(
        path: '/doctor/appointment/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DoctorAppointmentDetailScreen(appointmentId: id);
        },
      ),
      GoRoute(
        path: '/doctor/reviews',
        builder: (context, state) => const DoctorReviewsViewScreen(),
      ),
    ],
  );
}
