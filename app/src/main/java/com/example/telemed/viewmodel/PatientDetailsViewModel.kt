package com.example.telemed.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.viewModelScope
import androidx.room.Room
import com.example.telemed.data.local.AppDatabase
import com.example.telemed.data.local.EPrescription
import com.example.telemed.data.local.MedicalHistory
import com.example.telemed.data.local.User
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class PatientDetailsViewModel(application: Application, savedStateHandle: SavedStateHandle) : AndroidViewModel(application) {

    private val db = Room.databaseBuilder(
        application,
        AppDatabase::class.java, "telemed-db"
    ).fallbackToDestructiveMigration().build()

    private val patientId: Int = checkNotNull(savedStateHandle["patientId"])
    val appointmentId: Int = checkNotNull(savedStateHandle["appointmentId"])

    private val medicalHistory = db.medicalHistoryDao().getMedicalHistoryForPatient(patientId)
    private val ePrescriptions = db.ePrescriptionDao().getEPrescriptionsForPatient(patientId)
    val patient = db.userDao().getUserById(patientId)
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), null)

    val patientDetailsUiState = combine(medicalHistory, ePrescriptions) { history, prescriptions ->
        PatientDetailsUiState(history, prescriptions)
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), PatientDetailsUiState())

    fun addMedicalHistory(condition: String, date: String, doctorName: String) {
        viewModelScope.launch {
            db.medicalHistoryDao().insertMedicalHistory(
                MedicalHistory(
                    patientId = patientId,
                    condition = condition,
                    date = date,
                    doctorName = doctorName
                )
            )
        }
    }

    fun addEPrescription(medication: String, dosage: String, frequency: String, doctorName: String, date: String) {
        viewModelScope.launch {
            db.ePrescriptionDao().insertEPrescription(
                EPrescription(
                    patientId = patientId,
                    medication = medication,
                    dosage = dosage,
                    frequency = frequency,
                    doctorName = doctorName,
                    date = date
                )
            )
        }
    }
}

data class PatientDetailsUiState(
    val medicalHistory: List<MedicalHistory> = emptyList(),
    val ePrescriptions: List<EPrescription> = emptyList()
)