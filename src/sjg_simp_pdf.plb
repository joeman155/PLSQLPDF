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
-- * begin
-- *    sjg_simp_pdf.create_attachment (p_tender_number => '123',
-- *                                    p_month         => 'MAR-21',
-- *                                    p_file_name     => 'output.pdf');
-- * 
-- *  


  

  procedure create_attachment(p_tender_number  varchar2,
                              p_month          varchar2,
                              p_file_name      varchar2 := null) AS
  lv_page_title    varchar2(100);
  lvc_table1_title varchar2(25) := 'Transactions';
  lvc_table2_title varchar2(25) := 'Payment Methods';
  lvc_crlf         varchar2(2)  := chr(10) || chr(13);
  
  lv_default_font_family varchar2(100) := 'helvetica';
  lb_pdf           blob;


  table1_h        jt_pdf.tp_headers;
  table2_h        jt_pdf.tp_headers;
  header_font     tp_font_spec;
  cell_font       tp_font_spec;
  cell_font_bold  tp_font_spec;
  header_cell_attributes tp_cell_attributes;
  data_cell_attributes   tp_cell_attributes;
  data_cell_attributes3  tp_cell_attributes;
  lv_cond_fmt1           varchar2(32767);
  lv_cond_fmt2           varchar2(32767);
  
  q1 varchar2(32767) := q'[
                          select 'division' as division,
                                 'date'     as the_date,
                                 'invoice_number' as invoice_number,
                                 'menu_item'      as menu_item,
                                 to_char('$' || to_char(9.5, '99,999,99.99'))     as line_total,
                                 'Taxed'          as tax_flag
                          from dual
                          union
                          select 'division' as division,
                                 'date'     as the_date,
                                 'invoice_number' as invoice_number,
                                 'menu_item'      as menu_item,
                                 to_char('$' || to_char(3.6, '99,999,99.99'))     as line_total,
                                 'Taxed'          as tax_flag
                          from dual
                          union
                          select 'division' as division,
                                 'date'     as the_date,
                                 'invoice_number' as invoice_number,
                                 'menu_item'      as menu_item,
                                 to_char('')               as line_total,
                                 'Taxed'          as tax_flag
                          from dual
                          union
                          select '' as division,
                                 ''     as the_date,
                                 '' as invoice_number,
                                 ''      as menu_item,
                                 to_char('$' || to_char(13.10, '99,999,99.99'))            as line_total,
                                 ''          as tax_flag
                          from dual
                          ]';
  q2 varchar2(32767):= q'[
                          with q as (
                          select 1 as id,
                                 to_char('division') as division,
                                 to_char('date')     as the_date,
                                 to_char('invoice_number') as invoice_number,
                                 to_char('payment_method') as payment_method,
                                 to_char('$' || to_char(3.10, '99,999,99.99'))            as line_total
                          from dual
                          union
                          select 2 as id,
                                 to_char('division') as division,
                                 to_char('date')     as the_date,
                                 to_char('invoice_number') as invoice_number,
                                 to_char('payment_method') as payment_method,
                                 to_char('$' || to_char(10.00, '99,999,99.99'))            as line_total
                          from dual
                          union
                          select 3 as id,
                                 to_char('division') as division,
                                 to_char('date')     as the_date,
                                 to_char('invoice_number') as invoice_number,
                                 to_char('payment_method') as payment_method,
                                 to_char('$' || to_char(13.10, '99,999,99.99'))            as line_total
                          from dual
                          union
                          select 4 as id,
                                 to_char('')     as division,
                                 to_char('')     as the_date,
                                 to_char('')     as invoice_number,
                                 to_char('')     as payment_method,
                                 to_char(null)     as line_total
                          from dual
                          union
                          select 5 as id,
                                 to_char('')     as division,
                                 to_char('')     as the_date,
                                 to_char('')     as invoice_number,
                                 to_char('Amount Owning') as payment_method,
                                 to_char('$' || to_char(10, '99,999,99.99'))  as line_total
                          from dual
                          order by 1)
                          select division, the_date, invoice_number, payment_method, line_total, '' as blank
                          from q
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
    
    cell_font_bold :=   tp_font_spec(family  => lv_default_font_family, 
                                     fontstyle   => 'b', 
                                     fontsize => 10);
    
    
    header_cell_attributes := tp_cell_attributes(line_color => null,
                                                 fill_color => 'D9D9D9',
                                                 line_width => 0,
                                                 padding    => 6);
    
    data_cell_attributes := tp_cell_attributes(line_color => null,
                                               fill_color => 'FFFFFF',
                                               line_width => 0.0,
                                               padding    => 6);
                                                 

    data_cell_attributes3 := tp_cell_attributes(line_color => null,
                                                fill_color => 'FFFFFF',
                                                line_width => 0.0,
                                                padding    => 6);
                                                 
                                                


  
    lv_page_title := 'Cafe Account '||p_tender_number||' ' ||p_month;
  
    -- First line to initialize the package
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
                      

    lv_cond_fmt1 := q'[
                       begin
                       sjg_simp_pdf.cell_rule1( p_x_cell => :x,
                                                p_y_cell => :y,
                                                p_rows   => :r,
                                                o_cell_attributes => :ca,
                                                o_cell_font       => :cf
                                               );
                       end;
                      ]';

    lv_cond_fmt2 := q'[
                       begin
                       sjg_simp_pdf.cell_rule2( p_x_cell => :x,
                                                p_y_cell => :y,
                                                p_rows   => :r,
                                                o_cell_attributes => :ca,
                                                o_cell_font       => :cf
                                               );
                       end;
                      ]';


    -- First table
    -- lv_cond_fmt1 := null;  -- Uncomment this to remove conditional formatting
    jt_pdf.query2table( p_query     => q1, 
                        p_widths    => null, 
                        p_headers   => table1_h, 
                        p_cell_font => cell_font, 
                        p_header_font => header_font, 
                        p_data_cell_attributes => data_cell_attributes, 
                        p_header_cell_attributes => header_cell_attributes, 
                        p_conditional_fmt_fn => lv_cond_fmt1);


    new_line();
    
  
    
    -- Title for second table
    writeHeading (lvc_table2_title);
     
    jt_pdf.set_font (p_family => lv_default_font_family, 
                     p_style  => 'N',
                     p_fontsize_pt => 10);
                      
    -- Second table
    -- lv_cond_fmt2 := null;  -- Uncomment this to remove conditional formatting
    jt_pdf.query2table( p_query     => q2, 
                        p_widths    => null, 
                        p_headers   => table2_h, 
                        p_cell_font => cell_font, 
                        p_header_font => header_font, 
                        p_data_cell_attributes => data_cell_attributes, 
                        p_header_cell_attributes => header_cell_attributes, 
                        p_conditional_fmt_fn => lv_cond_fmt2);

    
    new_line();
    

    -- You can save it to a BLOB, instead of saving to a DIRECTORY.
    -- lb_pdf := jt_pdf.get_pdf();
   
    jt_pdf.save_pdf ('MY_PDF_DIR', p_file_name);
  END create_attachment;




  procedure cell_rule1 (p_x_cell in number,
                        p_y_cell in number,
                        p_rows   in number,
                        o_cell_attributes out tp_cell_attributes,
                        o_cell_font       out tp_font_spec) is
  l_cell_attributes tp_cell_attributes := null;
  l_cell_font       tp_font_spec       := null;
  begin


    if p_x_cell = 5 and p_y_cell = p_rows then
       l_cell_font := tp_font_spec(family  => 'helvetica',
                                   fontstyle   => 'b',
                                   fontsize => 10);


       l_cell_attributes := tp_cell_attributes(line_color => 'FFFFFF',
                                               fill_color => 'D9D9D9',
                                               line_width => 1,
                                               padding    => 6);
     end if;



     o_cell_attributes := l_cell_attributes;
     o_cell_font       := l_cell_font;
  end cell_rule1;




  procedure cell_rule2 (p_x_cell in number,
                        p_y_cell in number,
                        p_rows   in number,
                        o_cell_attributes out tp_cell_attributes,
                        o_cell_font       out tp_font_spec) is
  l_cell_attributes tp_cell_attributes := null;
  l_cell_font       tp_font_spec       := null;
  begin


    if (p_x_cell = 5 and (p_y_cell = p_rows or p_y_cell = p_rows - 2)) or
       (p_x_cell = 4 and p_y_cell = p_rows) then
       l_cell_font := tp_font_spec(family  => 'helvetica',
                                   fontstyle   => 'b',
                                   fontsize => 10);


       l_cell_attributes := tp_cell_attributes(line_color => null,
                                               fill_color => 'D9D9D9',
                                               line_width => 1,
                                               padding    => 6);
     end if;
   

  
     o_cell_attributes := l_cell_attributes;
     o_cell_font       := l_cell_font;
  end cell_rule2;

END SJG_SIMP_PDF;
/


show errors;


quit;
