create or replace PACKAGE SJG_SIMP_PDF AS 

   
  /* Create an attachment PDF with some tables. */
  procedure create_attachment(p_tender_number  varchar2,
                              p_month          varchar2,
                              p_file_name      varchar2 := null);
                               

  /* Rule to determine cell attributes based on position */
  /* i.e. Conditional formatting                         */
  procedure cell_rule (p_x_cell in number,
                       p_y_cell in number,
                       p_rows   in number,
                       o_cell_attributes out tp_cell_attributes,
                       o_cell_font       out tp_font_spec);

END SJG_SIMP_PDF;
/
