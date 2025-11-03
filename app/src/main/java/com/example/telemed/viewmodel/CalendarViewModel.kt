package com.example.telemed.viewmodel

import android.app.Application
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.DoctorAvailability
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class CalendarViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    // This is a placeholder for the actual doctor ID
    private val doctorId = 1

    val availability = db.doctorAvailabilityDao().getAvailabilityForDoctor(doctorId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    var date by mutableStateOf("")
    var startTime by mutableStateOf("")
    var endTime by mutableStateOf("")

    fun addAvailability() {
        viewModelScope.launch {
            db.doctorAvailabilityDao().insertAvailability(
                DoctorAvailability(
                    doctorId = doctorId,
                    date = date,
                    startTime = startTime,
                    endTime = endTime
                )
            )
        }
    }

    fun deleteAvailability(availability: DoctorAvailability) {
        viewModelScope.launch {
            db.doctorAvailabilityDao().deleteAvailability(availability)
        }
    }
}
