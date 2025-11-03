package com.example.telemed

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.telemed.ui.ChatScreen
import com.example.telemed.ui.SettingsScreen
import com.example.telemed.ui.VideoCallScreen
import com.example.telemed.ui.doctor.*
import com.example.telemed.ui.patient.*
import com.example.telemed.ui.signin.SignInScreen
import com.example.telemed.ui.signup.SignUpScreen
import com.example.telemed.ui.theme.TelemedTheme

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            TelemedTheme {
                TelemedApp()
            }
        }
    }
}

@Composable
fun TelemedApp() {
    val navController = rememberNavController()

    NavHost(navController = navController, startDestination = "signin") {
        // Auth Flow
        composable("signin") {
            SignInScreen(
                onSignUpClicked = { navController.navigate("signup") },
                onSignInSuccess = { role ->
                    val destination = if (role == "Doctor") "doctor_dashboard" else "patient_dashboard"
                    navController.navigate(destination) {
                        popUpTo("signin") { inclusive = true }
                    }
                }
            )
        }
        composable("signup") {
            SignUpScreen(navController = navController)
        }

        // Patient Flow
        composable("patient_dashboard") {
            PatientDashboardScreen(navController)
        }
        composable(PatientScreen.BookAppointment.route) {
            BookAppointmentScreen()
        }
        composable(PatientScreen.ViewAppointments.route) {
            ViewAppointmentsScreen(navController = navController)
        }
        composable(PatientScreen.Ehr.route) {
            EhrScreen()
        }
        composable(PatientScreen.Settings.route) {
            SettingsScreen()
        }
        composable(
            route = PatientScreen.Chat.route,
            arguments = listOf(
                navArgument("appointmentId") { type = NavType.IntType },
                navArgument("receiverId") { type = NavType.IntType }
            )
        ) {
            val receiverId = it.arguments?.getInt("receiverId") ?: -1
            ChatScreen(receiverId = receiverId)
        }
        composable(PatientScreen.VideoCall.route) {
            VideoCallScreen(navController)
        }

        // Doctor Flow
        composable("doctor_dashboard") {
            DoctorDashboardScreen(navController)
        }
        composable(DoctorScreen.Calendar.route) {
            CalendarScreen()
        }
        composable(DoctorScreen.PatientRecords.route) {
            PatientRecordsScreen(navController = navController)
        }
        composable(
            route = DoctorScreen.PatientDetails.route,
            arguments = listOf(
                navArgument("appointmentId") { type = NavType.IntType },
                navArgument("patientId") { type = NavType.IntType }
            )
        ) {
            PatientDetailsScreen(navController = navController)
        }
    }
}