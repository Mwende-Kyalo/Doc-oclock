package com.example.telemed.ui.doctor

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

sealed class DoctorScreen(val route: String, val title: String) {
    object Calendar : DoctorScreen("calendar", "Manage Calendar")
    object PatientRecords : DoctorScreen("patient_records", "Patient Records")
    object Settings : DoctorScreen("settings", "Settings")
    object PatientDetails : DoctorScreen("patient_details/{appointmentId}/{patientId}", "Patient Details")
    object Chat : DoctorScreen("chat/{appointmentId}/{receiverId}", "Chat")
    object VideoCall : DoctorScreen("video_call", "Video Call")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DoctorDashboardScreen(navController: NavController) {
    val nestedNavController = rememberNavController()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()

    val navigationItems = listOf(
        DoctorScreen.Calendar,
        DoctorScreen.PatientRecords,
        DoctorScreen.Settings
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
                    title = { Text("Doctor Dashboard") },
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
                startDestination = DoctorScreen.PatientRecords.route,
                modifier = Modifier.padding(paddingValues)
            ) {
                composable(DoctorScreen.Calendar.route) {
                    CalendarScreen()
                }
                composable(DoctorScreen.PatientRecords.route) {
                    PatientRecordsScreen(navController = nestedNavController)
                }
                composable(DoctorScreen.Settings.route) {
                    SettingsScreen()
                }
                composable(
                    route = DoctorScreen.PatientDetails.route,
                    arguments = listOf(
                        navArgument("appointmentId") { type = NavType.IntType },
                        navArgument("patientId") { type = NavType.IntType }
                    )
                ) {
                    PatientDetailsScreen(navController = nestedNavController)
                }
                composable(
                    route = DoctorScreen.Chat.route,
                    arguments = listOf(
                        navArgument("appointmentId") { type = NavType.IntType },
                        navArgument("receiverId") { type = NavType.IntType }
                    )
                ) {
                    val receiverId = it.arguments?.getInt("receiverId") ?: -1
                    ChatScreen(receiverId = receiverId)
                }
                composable(DoctorScreen.VideoCall.route) {
                    VideoCallScreen(nestedNavController)
                }
            }
        }
    }
}

@Preview(showBackground = true)
@Composable
fun DoctorDashboardScreenPreview() {
    TelemedTheme {
        DoctorDashboardScreen(navController = rememberNavController())
    }
}