<?php
require('../vendor/setasign/fpdf/fpdf.php');

$pdf = new FPDF();
$pdf->AddPage();
$pdf->SetFont('Arial','B',16);
$pdf->Cell(0,10,'Telemedicine USSD & Mobile Insights Report',0,1,'C');
$pdf->Ln(10);

$pdf->SetFont('Arial','',12);
$pdf->Cell(0,10,'Report Generated On: ' . date('Y-m-d H:i:s'),0,1);
$pdf->Ln(10);

// Example dummy data (replace with actual DB fetch)
$pdf->Cell(0,10,'Total Transactions Today: 120',0,1);
$pdf->Cell(0,10,'Successful Transactions: 110',0,1);
$pdf->Cell(0,10,'Failed Transactions: 10',0,1);
$pdf->Cell(0,10,'Registered App Users (Month): 50',0,1);

$pdf->Output('D', 'Telemedicine_Insights_Report.pdf');
?>
