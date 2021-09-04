create or replace PACKAGE SJG_SIMP_PDF AS 

   
  /* Create an attachment PDF with some tables. */
  procedure create_attachment (p_file_name     varchar2,
                               p_tender_number varchar2,
                               p_month         varchar2);
                               

END SJG_SIMP_PDF;
/


