package com.example.telemed.ui.patient

import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalInspectionMode
import androidx.compose.ui.tooling.preview.Preview
import androidx.navigation.NavController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
import com.example.telemed.ui.ChatScreen
import com.example.telemed.ui.SettingsScreen
import com.example.telemed.ui.VideoCallScreen
import com.example.telemed.ui.theme.TelemedTheme
import kotlinx.coroutines.launch

sealed class PatientScreen(val route: String, val title: String) {
    object BookAppointment : PatientScreen("book_appointment", "Book Appointment")
    object ViewAppointments : PatientScreen("view_appointments", "View Appointments")
    object Ehr : PatientScreen("ehr", "EHR")
    object Settings : PatientScreen("settings", "Settings")
    object Chat : PatientScreen("chat/{appointmentId}/{receiverId}", "Chat")
    object VideoCall : PatientScreen("video_call", "Video Call")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PatientDashboardScreen(navController: NavController) {
    val nestedNavController = rememberNavController()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    val navigationItems = listOf(
        PatientScreen.BookAppointment,
        PatientScreen.ViewAppointments,
        PatientScreen.Ehr,
        PatientScreen.Settings
    )

    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet {
                navigationItems.forEach { screen ->
                    NavigationDrawerItem(
                        label = { Text(text = screen.title) },
                        selected = false,
                        onClick = {
                            nestedNavController.navigate(screen.route)
                            scope.launch {
                                drawerState.close()
                            }
                        }
                    )
                }
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { Text("Patient Dashboard") },
                    navigationIcon = {
                        IconButton(onClick = {
                            scope.launch {
                                drawerState.apply {
                                    if (isClosed) open() else close()
                                }
                            }
                        }) {
                            Icon(Icons.Filled.Menu, contentDescription = "Menu")
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = Color(0xFF000428) ,
                        titleContentColor = Color.White,
                        navigationIconContentColor = Color.White
                    )
                )
            }
        ) { paddingValues ->
            NavHost(
                navController = nestedNavController,
                startDestination = PatientScreen.ViewAppointments.route,
                modifier = Modifier.padding(paddingValues)
            ) {
                composable(PatientScreen.BookAppointment.route) {
                    BookAppointmentScreen()
                }
                composable(PatientScreen.ViewAppointments.route) {
                    ViewAppointmentsScreen(navController = nestedNavController)
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
                    VideoCallScreen(nestedNavController)
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun PatientDashboardScreenPreview() {
    TelemedTheme {
        PatientDashboardScreen(navController = rememberNavController())
    }
}
