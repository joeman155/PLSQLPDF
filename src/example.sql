
create or replace PACKAGE SJG_SIMP_PDF AS 

   
  /* Create an attachment PDF with some tables. */
  procedure create_attachment (p_tender_number varchar2,
                               p_month         varchar2);
                               

END SJG_SIMP_PDF;
/


create or replace PACKAGE BODY SJG_SIMP_PDF AS

-- *
-- *
-- *
-- * PREPARATION STEPS
-- * We need to perform a bit of configuration first off.
-- *
-- * As SYSDBA User
-- * SQL> create or replace DIRECTORY MY_PDF_DIR as '/tmp/';
-- * 
-- * 
-- * SQL> grant read, write on DIRECTORY MY_PDF_DIR to joeman;
-- * 
-- * Here we assume the user to create/save PDF is user joeman. Set it to your user.
-- * 
-- * EXAMPLE USAGE
-- * 
-- * call sjg_simp_pdf.create_attachment;
-- * 
-- *  


  

  procedure create_attachment(p_tender_number varchar2,
                               p_month         varchar2) AS
  lv_page_title    varchar2(100);
  lvc_table1_title varchar2(25) := 'Transactions';
  lvc_table2_title varchar2(25) := 'Payment Methods';
  lvc_crlf         varchar2(2)  := chr(10) || chr(13);
  
  lv_default_font_family varchar2(100) := 'helvetica';
  lb_pdf           blob;

/*
  table1 t_table_headings_type;
  table2 t_table_headings_type;
  
  table1_col t_table_numbers_type;
  table2_col t_table_numbers_type;
*/

  t_query varchar2(1000);
  table1_h jt_pdf.tp_headers;
  table2_h jt_pdf.tp_headers;
  header_font tp_font_spec;
  cell_font   tp_font_spec;
  header_cell_attributes tp_cell_attributes;
  data_cell_attributes   tp_cell_attributes;
  
  q1 varchar2(32767) := q'[
                          select 'division' as division,
                                 'date'     as the_date,
                                 'invoice_number' as invoice_number,
                                 'menu_item'      as menu_item,
                                 12345            as line_total,
                                 'Taxed'          as tax_flag
                          from dual
                          ]';
  q2 varchar2(32767):= q'[
                          select 'division' as division,
                                 'date'     as the_date,
                                 'invoice_number' as invoice_number,
                                 'payment_method' as payment_method,
                                 12345            as line_total
                          from dual
                          ]';
   
  
  procedure new_line IS
  BEGIN
     jt_pdf.write (lvc_crlf);
  END new_line;

 
  
  procedure writeHeading(p_text in varchar2) is
  begin
  
    /* Set the font to bold for heading*/
    jt_pdf.set_font (p_family => lv_default_font_family, 
                              p_style  => 'b',
                              p_fontsize_pt => 14);
    
    jt_pdf.write (p_txt => p_text, p_x => 0);
    -- new_line();
    
  end writeHeading;
  
  
  
  BEGIN
  
    table1_h := jt_pdf.tp_headers('Division', 'Date', 'Invoice Number', 'Menu Item', 'Line Total', 'Taxed/Tax Free');
    table2_h := jt_pdf.tp_headers('Division', 'Date', 'Invoice Number', 'Payment Method', 'Line Total');  
  
    header_font := tp_font_spec(family => lv_default_font_family, 
                                fontstyle  => 'b', 
                                fontsize => 10);
    cell_font :=   tp_font_spec(family  => lv_default_font_family, 
                                fontstyle   => 'N', 
                                fontsize => 10);
    
    
    header_cell_attributes := tp_cell_attributes(line_color => null,
                                                 fill_color => 'ACACAC',
                                                 line_width => 0,
                                                 padding    => 6);
    
    data_cell_attributes := tp_cell_attributes(line_color => null,
                                               fill_color => 'FFFFFF',
                                               line_width => 0.0,
                                               padding    => 6);
                                                 
                                                


  
    lv_page_title := 'Cafe Account '||p_tender_number||' ' ||p_month;
  
    /* First line to initialize the package*/
    jt_pdf.init;
    jt_pdf.set_page_orientation('L');
    

    -- Set the font to bold for heading    
    jt_pdf.set_font (p_family => lv_default_font_family, 
                      p_style  => 'b',
                      p_fontsize_pt => 16);

    jt_pdf.write (lv_page_title);
    new_line();

    -- Title for first table 
    writeHeading (lvc_table1_title);
     
    jt_pdf.set_font (p_family => lv_default_font_family, 
                      p_style  => 'N',
                      p_fontsize_pt => 10);
                      
    -- First table
    jt_pdf.query2table( q1, null, table1_h, cell_font, header_font, data_cell_attributes, header_cell_attributes );
    
    new_line();
    
  
    
    -- Title for second table
    writeHeading (lvc_table2_title);
     
    jt_pdf.set_font (p_family => lv_default_font_family, 
                      p_style  => 'N',
                      p_fontsize_pt => 10);
                      
    -- Second table
    jt_pdf.query2table( q2, null, table2_h, cell_font, header_font, data_cell_attributes, header_cell_attributes );    
    
    new_line();
    

    -- You can save it to a BLOB, instead of saving to a DIRECTORY.
    -- lb_pdf := jt_pdf.get_pdf();
   
    jt_pdf.save_pdf ('MY_PDF_DIR', 'emp_report.pdf');
  END create_attachment;

END SJG_SIMP_PDF;
/
