package com.example.telemed

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.telemed.data.AppDatabase
import com.example.telemed.ui.auth.AuthViewModel
import com.example.telemed.ui.auth.AuthViewModelFactory
import com.example.telemed.ui.auth.AuthState
import com.example.telemed.ui.auth.OtpVerificationScreen
import com.example.telemed.ui.auth.SignInScreen
import com.example.telemed.ui.auth.SignUpScreen
import com.example.telemed.ui.doctor.AppointmentDetailScreen
import com.example.telemed.ui.doctor.DoctorDashboardScreen
import com.example.telemed.ui.doctor.DoctorViewModel
import com.example.telemed.ui.doctor.DoctorViewModelFactory
import com.example.telemed.ui.doctor.EhrEditScreen
import com.example.telemed.ui.doctor.PatientHistoryScreen
import com.example.telemed.ui.theme.TelemedTheme

class MainActivity : ComponentActivity() {
    private val database by lazy { AppDatabase.getDatabase(this) }
    private val authViewModel: AuthViewModel by viewModels { AuthViewModelFactory(database.userDao()) }
    private val doctorViewModel: DoctorViewModel by viewModels {
        DoctorViewModelFactory(database.appointmentDao(), database.patientDao(), database.ehrDao())
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            TelemedTheme {
                TelemedApp(authViewModel, doctorViewModel)
            }
        }
    }
}

@Composable
fun TelemedApp(
    authViewModel: AuthViewModel,
    doctorViewModel: DoctorViewModel
) {
    val navController = rememberNavController()
    val authState by authViewModel.authState.collectAsState()

    LaunchedEffect(authState) {
        when (authState) {
            is AuthState.OtpSent -> navController.navigate("otp")
            is AuthState.Success -> {
                navController.navigate("doctor_dashboard") {
                    popUpTo(navController.graph.startDestinationId) { inclusive = true }
                }
            }
            else -> Unit
        }
    }

    NavHost(navController = navController, startDestination = "signup") {
        // --- Authentication Flow ---
        composable("signup") {
            SignUpScreen(
                onSignUpClicked = { fullName, email, phoneNumber, role, password ->
                    authViewModel.signUp(fullName, email, phoneNumber, role, password, password)
                },
                onLoginClicked = { navController.navigate("signin") }
            )
        }
        composable("signin") {
            SignInScreen(
                onSignInClicked = { email, password ->
                    authViewModel.signIn(email, password)
                },
                onSignUpClicked = { navController.popBackStack() }
            )
        }
        composable("otp") {
            OtpVerificationScreen(
                onVerifyClicked = { otp ->
                    authViewModel.verifyOtpAndCreateUser(otp)
                },
                onResendClicked = { /* Resend OTP logic */ }
            )
        }

        // --- Doctor Flow ---
        composable("doctor_dashboard") {
            val appointments by doctorViewModel.upcomingAppointments.collectAsState()
            DoctorDashboardScreen(
                appointments = appointments,
                onAppointmentClicked = { appointment ->
                    navController.navigate("appointment_detail/${appointment.id}")
                }
            )
        }

        composable(
            "appointment_detail/{appointmentId}",
            arguments = listOf(navArgument("appointmentId") { type = NavType.StringType })
        ) { backStackEntry ->
            val appointmentId = backStackEntry.arguments?.getString("appointmentId")
            val appointments by doctorViewModel.upcomingAppointments.collectAsState()
            val appointment = appointments.find { it.id == appointmentId }

            if (appointment != null) {
                val patient by doctorViewModel.getPatient(appointment.patientId).collectAsState()
                if (patient != null) {
                    AppointmentDetailScreen(
                        appointment = appointment,
                        patient = patient!!,
                        onNavigateBack = { navController.popBackStack() },
                        onStartCall = { /* TODO: Implement call logic */ },
                        onViewHistory = { patientId ->
                            navController.navigate("patient_history/$patientId")
                        },
                        onEditAppointment = { /* TODO: Implement edit logic */ }
                    )
                }
            }
        }

        composable(
            "patient_history/{patientId}",
            arguments = listOf(navArgument("patientId") { type = NavType.StringType })
        ) { backStackEntry ->
            val patientId = backStackEntry.arguments?.getString("patientId") ?: return@composable
            val patient by doctorViewModel.getPatient(patientId).collectAsState()
            val ehrList by doctorViewModel.getEHRForPatient(patientId).collectAsState()

            if (patient != null) {
                PatientHistoryScreen(
                    patient = patient!!,
                    ehrList = ehrList,
                    onNavigateBack = { navController.popBackStack() },
                    onAddEhr = { pId ->
                        navController.navigate("ehr_edit/$pId")
                    },
                    onEhrClicked = { ehr ->
                         navController.navigate("ehr_edit/${ehr.patientId}?ehrId=${ehr.id}")
                    }
                )
            }
        }
        
        composable(
            "ehr_edit/{patientId}?ehrId={ehrId}",
            arguments = listOf(
                navArgument("patientId") { type = NavType.StringType },
                navArgument("ehrId") { type = NavType.IntType; defaultValue = -1 }
            )
        ) { backStackEntry ->
             val patientId = backStackEntry.arguments?.getString("patientId") ?: return@composable
             val ehrId = backStackEntry.arguments?.getInt("ehrId")

             EhrEditScreen(
                 ehr = null, // In a real app, you would fetch the EHR here if ehrId is not -1
                 patientId = patientId,
                 onNavigateBack = { navController.popBackStack() },
                 onSaveEhr = { ehr ->
                     doctorViewModel.saveEHR(ehr)
                     navController.popBackStack()
                 }
             )
        }
    }
}
