package com.example.telemed.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.EPrescription
import com.example.telemed.data.local.MedicalHistory
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn

class EhrViewModel(application: Application) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    // This is a placeholder for the actual patient ID
    private val patientId = 1

    private val medicalHistory = db.medicalHistoryDao().getMedicalHistoryForPatient(patientId)
    private val ePrescriptions = db.ePrescriptionDao().getEPrescriptionsForPatient(patientId)

    val ehrUiState = combine(medicalHistory, ePrescriptions) { history, prescriptions ->
        EhrUiState(history, prescriptions)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), EhrUiState())
}

data class EhrUiState(
    val medicalHistory: List<MedicalHistory> = emptyList(),
    val ePrescriptions: List<EPrescription> = emptyList()
)