package com.example.telemed.data

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface EHRDao {
    @Query("SELECT * FROM ehr WHERE patientId = :patientId ORDER BY date DESC")
    fun getEHRForPatient(patientId: String): Flow<List<EHR>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrUpdateEHR(ehr: EHR)
}
