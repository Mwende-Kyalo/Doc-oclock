package com.example.telemed.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface EPrescriptionDao {
    @Insert
    suspend fun insertEPrescription(ePrescription: EPrescription)

    @Query("SELECT * FROM e_prescriptions WHERE patientId = :patientId")
    fun getEPrescriptionsForPatient(patientId: Int): Flow<List<EPrescription>>
}