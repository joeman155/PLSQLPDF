create or replace type tp_font_spec as object 
(
    family varchar2(100),
    fontstyle varchar2(2),
    fontsize number
);



create or replace type tp_cell_attributes as object 
(
    line_color varchar2(6),
    fill_color varchar2(6),
    line_width number,
    padding    number
);
