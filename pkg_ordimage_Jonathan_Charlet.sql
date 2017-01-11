
create or replace package pkg_ordimage_DJ as

  -- diplay all the attributes from an image (blob) -->   SET serveroutput ON;
  procedure  displayAttributs(p_image  blob);

  -- Return a new BLOB image (180x180), facebook profil picture  from an image model (Please respect model width and height --> 851x363)
  function facebookProfilCut(p_image blob) return blob;

  -- Return a new BLOB image (851x315) , facebook background picture from an image model (Please respect model width and height --> 851x363)
  function facebookBackgroundCut(p_image blob) return blob;

  -- Return a new BLOB image (430x520), Add a polaroid style frame to an image (Please input a square pictures)
  function polaroidFrame(p_image blob) return blob;

  -- Return a new BLOB image (430x520), Add a polaroid style frame to an image with a text (Please input a square pictures)
  function polaroidFrame(p_image blob, p_text varchar2) return blob;

  -- Return a new BLOB image, cut the border top of an image
   function cutBorderTop(p_image blob, p_top number) return blob;

  -- Return a new BLOB image, cut the border bottom of an image
  function cutBorderBottom(p_image blob, p_bottom number) return blob;

  -- Return a new BLOB image, cut the border left of an image
  function cutBorderleft(p_image blob, p_left number) return blob;

  -- Return a new BLOB image, cut the border right of an image
  function cutBorderRight(p_image blob,  p_right number) return blob;

  -- Return a new BLOB image, cut the borders of an image
  function cutBorder(p_image blob, p_top number, p_bottom number, p_left number,  p_right number) return blob;

  -- Return a new BLOB image, past two image to make one (from top border)
  function pastUp(p_imageTop blob, p_imageDown blob) return blob;

  -- Return a new BLOB image, past two image to make one (from side border)
  function pastSide(p_imageLeft blob, p_imageRight blob) return blob;

  -- Return a new BLOB image (420x420), create a random profil image like on GitHub
  function GitHubProfil return blob;

  -- Return a new BLOB image, add a border top to an image
  function addBorderTop(p_image blob, p_top number) return blob;

  -- Return a new BLOB image, add a border bottom to an image
  function addBorderBottom(p_image blob, p_bottom number) return blob;

  -- Return a new BLOB image, add a border left to an image
  function addBorderleft(p_image blob, p_left number) return blob;

  -- Return a new BLOB image, add a border right to an image
  function addBorderRight(p_image blob,  p_right number) return blob;

  -- Return a new BLOB image, add borders to an image
  function addBorder(p_image blob, p_top number, p_bottom number, p_left number,  p_right number) return blob;

end pkg_ordimage_DJ;
/




--
--++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
--

create or replace package body pkg_ordimage_DJ as

-- PRIVATE PROCEDURE AND FUNCTIONS

function facebookFixScale(p_image blob) return blob as
    res BLOB;
  begin
    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

    -- Ajustement des dimensions de la maquette
    ORDSYS.ORDIMAGE.processCopy(p_image,'fixedScale=851 363',res);

    return res;
  end facebookFixScale;



-- PUBLIC PROCDURES AND FUNCTIONS
-- ###
  procedure  displayAttributs(p_image  blob) as
      obj ordsys.ordimage;
    begin
      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Affichage des attributs
      DBMS_OUTPUT.PUT_LINE('ATTRIBUTS of the image BLOB file');
      DBMS_OUTPUT.PUT_LINE('-------');
      DBMS_OUTPUT.PUT_LINE('File format is : ' || obj.getFileFormat());
      DBMS_OUTPUT.PUT_LINE('Height is : ' || obj.getHeight() || ' px');
      DBMS_OUTPUT.PUT_LINE('Width is : ' || obj.getWidth() || ' px');
      DBMS_OUTPUT.PUT_LINE('Compression format is : ' || obj.getCompressionFormat());
      DBMS_OUTPUT.PUT_LINE('Content format is : ' || obj.getContentFormat());
      DBMS_OUTPUT.PUT_LINE('Content length is : ' || obj.getContentLength() || ' Bytes');
      DBMS_OUTPUT.PUT_LINE('Image mime type = ' || obj.getMimeType());
      DBMS_OUTPUT.PUT_LINE('Last update = ' || obj.getUpdateTime());
    end displayAttributs;

-- ###

  function facebookProfilCut(p_image blob) return blob AS
      res blob;
    begin
      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Ajustement des dimensions de la maquette
      res := facebookFixScale(p_image);

      -- Découpage de la photo de profil depuis l'image maquette
      ORDSYS.ORDIMAGE.process(res,'cut=28 198 160 160');

      -- Ajustement à une taille très légérement supérieur de l'image pour respecter la taille minimum de facebook
      ORDSYS.ORDIMAGE.process(res,'fixedScale=180 180');

      return res;
    end facebookProfilCut;

-- ###

  function facebookBackgroundCut(p_image blob) return blob AS
      res blob;
    begin
      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Ajustement des dimensions de la maquette
      res := facebookFixScale(p_image);

      -- Découpage de la photo de background depuis l'image maquette
      ORDSYS.ORDIMAGE.process(res,'cut=0 0 851 315');


      return res;
    end facebookBackgroundCut;

-- ###

    function polaroidFrame(p_image blob) return blob AS
      res blob;
      backgroundFrame blob;
      vignette blob;
      logging VARCHAR2(2000);
      prop ordsys.ord_str_list;
    begin

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(backgroundFrame,TRUE, DBMS_LOB.SESSION);

      -- Création d'un PNG de 10x10x blanc depuis son code hexadécimal dans un blob
      backgroundFrame := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

      -- Propriétés de l'emplacement de l'image (transparence à 90% délibéré pour un effet "glossy")
      prop := ordsys.ord_str_list(
                   'position_x=30',
                   'position_y=30',
                   'transparency=0.9');

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(vignette,TRUE, DBMS_LOB.SESSION);

      -- Ajustement des dimensions de la vignette (370x370)
      ORDSYS.ORDIMAGE.processCopy(p_image,'fixedScale=370 370',vignette);

      -- Ajustement des dimensions de fond pour avoir le cadre "polaroid" (430x520)
      ORDSYS.ORDIMAGE.process(backgroundFrame,'fixedScale=430 520');

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Ajout de la vignette sur l'image de fond
      ORDSYS.ORDImage.applyWatermark(backgroundFrame, vignette, res, logging, prop);

      return res;
    end polaroidFrame;

-- ###

    function polaroidFrame(p_image blob, p_text varchar2) return blob AS
      polaroidBase blob;
      res blob;
      logging VARCHAR2(2000);
      prop ordsys.ord_str_list;
    begin
      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(polaroidBase,TRUE, DBMS_LOB.SESSION);

      -- Création de la photo "polaroid" de base
      polaroidBase:= polaroidFrame(p_image);

      -- Propriétés de l'emplacement du text (transparence à 90% délibéré pour un effet "glossy")
      -- REMARQUE : la police utilisée est Dialog pour éviter une erreur. Par défaut la police Arial est utilisée mais n'est apparement pas disponible
      prop := ordsys.ord_str_list(
                       'font_name=Dialog',
                       'font_size=101',
                       'text_color=gray',
                       'position_x=30',
                       'position_y=490',
                       'transparency=0.9');

        -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Ajout du texte sur l'image polaroid de base
      ORDSYS.ORDImage.applyWatermark(polaroidBase, p_text, res, logging, prop);

      return res;
    end polaroidFrame;

-- ###

    function cutBorderTop(p_image blob, p_top number) return blob AS
      res blob;
      obj ordsys.ordimage;
      height number;
      width number;
    begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel moins ce qu'il faut couper
      height := obj.getHeight() - p_top;

      -- Récupération de la largeur de l'image actuel
      width := obj.getWidth();

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Création d'une nouvelle image sans la partie découpée en haut
      ORDSYS.ORDIMAGE.processCopy(p_image, 'cut=0 '||p_top||' '||width||' '||height, res);

      return res;
    end cutBorderTop;

-- ###

    function cutBorderBottom(p_image blob, p_bottom number) return blob AS
      res blob;
      obj ordsys.ordimage;
      height number;
      width number;
    begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel moins ce qu'il faut couper
      height := obj.getHeight() - p_bottom;

      -- Récupération de la largeur de l'image actuel
      width := obj.getWidth();

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Création d'une nouvelle image sans la partie découpée en bas
      ORDSYS.ORDIMAGE.processCopy(p_image,'cut=0 0 ' ||width|| ' ' ||height ,res);

      return res;
    end cutBorderBottom;

-- ###

    function cutBorderLeft(p_image blob, p_left number) return blob AS
      res blob;
      obj ordsys.ordimage;
      height number;
      width number;
    begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel
      height := obj.getHeight();

      -- Récupération de la largeur de l'image actuel moins ce qu'il faut couper
      width := obj.getWidth() - p_left;

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Création d'une nouvelle image sans la partie découpée en bas
      ORDSYS.ORDIMAGE.processCopy(p_image,'cut=' ||p_left|| ' 0 ' ||width|| ' ' ||height ,res);

      return res;
    end cutBorderLeft;

-- ###

    function cutBorderRight(p_image blob, p_right number) return blob AS
      res blob;
      obj ordsys.ordimage;
      height number;
      width number;
    begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel
      height := obj.getHeight();

      -- Récupération de la largeur de l'image actuel moins ce qu'il faut couper
      width := obj.getWidth() - p_right;

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Création d'une nouvelle image sans la partie découpée en bas
      ORDSYS.ORDIMAGE.processCopy(p_image,'cut=0 0 ' ||width|| ' ' ||height ,res);

      return res;
    end cutBorderRight;

-- ###

    function cutBorder(p_image blob, p_top number, p_bottom number, p_left number,  p_right number)  return blob AS
      res blob;
    begin

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Découpage du dessus de l'image
      res:= cutBorderTop(p_image,p_top);

      -- Découpage du dessous de l'image
      res:= cutBorderBottom(res,p_bottom);

      -- Découpage de la partie gauche de l'image
      res:= cutBorderLeft(res,p_left);

      -- Découpage de la partie droite de l'image
      res:= cutBorderRight(res,p_right);

      return res;
    end cutBorder;

-- ###

    function pastUp(p_imageTop blob, p_imageDown blob) return blob AS
      backgroundImage1 blob;
      background blob;
      res blob;
      objDown ordsys.ordimage;
      objTop ordsys.ordimage;
      heightImgDown number;
      widthImgDown number;
      heightImgTop number;
      widthImgTop number;
      widthRes number;
      heigtRes number;
      loggingDown VARCHAR2(2000);
      propDown ordsys.ord_str_list;
      loggingTop VARCHAR2(2000);
      propTop ordsys.ord_str_list;
    begin

    -- Transformation du BLOB en type ORDImage
    objDown := ORDSYS.ORDImage(p_imageDown,1);

    -- Transformation du BLOB en type ORDImage
    objTop := ORDSYS.ORDImage(p_imageTop,1);

    -- Récupération de la hauteur de l'image actuel
    heightImgDown := objDown.getHeight();

    -- Récupération de la largeur de l'image actuel
    widthImgDown := objDown.getWidth();

    -- Récupération de la hauteur de l'image actuel
    heightImgTop := objTop.getHeight();

    -- Récupération de la largeur de l'image actuel
    widthImgTop := objTop.getWidth();

    -- Si la largeur de l'image 1 est plus grande que la largeur de l'image 2
    IF widthImgDown > widthImgTop THEN

      -- la largeur de l'image 1 devient notre référence
      widthRes := widthImgDown;

    ELSE

      -- la largeur de l'image 2 devient notre référence
      widthRes := widthImgTop;

    END IF;

    -- La hauteur devient logiquement la somme des hauteurs des deux images
    heigtRes := heightImgDown + heightImgTop;

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

    -- Création de l'image dans le blob
    background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

    -- Ajustement des dimensions de l'image résultat
    ORDSYS.ORDIMAGE.process(background,'fixedScale=' ||widthRes|| ' ' ||heigtRes);

    -- Propriétés de l'emplacement de l'image du bas
    propDown := ordsys.ord_str_list(
                 'position_x=0',
                 'position_y='||heightImgTop,
                 'transparency=1');


    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(backgroundImage1,TRUE, DBMS_LOB.SESSION);

    -- Ajout de l'image du bas sur l'image de fond
    ORDSYS.ORDImage.applyWatermark(background, p_imageDown, backgroundImage1, loggingDown, propDown);

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

    -- Propriétés de l'emplacement de l'image du haut
    propTop := ordsys.ord_str_list(
                 'position_x=0',
                 'position_y=0',
                 'transparency=1');

    -- Ajout de l'image du haut sur l'image de fond
    ORDSYS.ORDImage.applyWatermark(backgroundImage1, p_imageTop, res, loggingTop, propTop);

      return res;
    end pastUp;

-- ###

    function pastSide(p_imageLeft blob, p_imageRight blob) return blob AS
      backgroundImage1 blob;
      background blob;
      res blob;
      objLeft ordsys.ordimage;
      objRight ordsys.ordimage;
      heightImgLeft number;
      widthImgLeft number;
      heightImgRight number;
      widthImgRight number;
      widthRes number;
      heigtRes number;
      loggingLeft VARCHAR2(2000);
      propLeft ordsys.ord_str_list;
      loggingRight VARCHAR2(2000);
      propRight ordsys.ord_str_list;
    begin

    -- Transformation du BLOB en type ORDImage
    objLeft := ORDSYS.ORDImage(p_imageLeft,1);

    -- Transformation du BLOB en type ORDImage
    objRight := ORDSYS.ORDImage(p_imageRight,1);

    -- Récupération de la hauteur de l'image actuel
    heightImgLeft := objLeft.getHeight();

    -- Récupération de la largeur de l'image actuel
    widthImgLeft := objLeft.getWidth();

    -- Récupération de la hauteur de l'image actuel
    heightImgRight := objRight.getHeight();

    -- Récupération de la largeur de l'image actuel
    widthImgRight := objRight.getWidth();

    -- Si la largeur de l'image 1 est plus grande que la largeur de l'image 2
    IF heightImgLeft > heightImgRight THEN

      -- la largeur de l'image 1 devient notre référence
      heigtRes := heightImgLeft;

    ELSE

      -- la largeur de l'image 2 devient notre référence
    heigtRes := heightImgRight;

    END IF;

    -- La hauteur devient logiquement la somme des hauteurs des deux images
    widthRes := widthImgLeft + widthImgRight;

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

    -- Création de l'image dans le blob
    background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

    -- Ajustement des dimensions de l'image résultat
    ORDSYS.ORDIMAGE.process(background,'fixedScale=' ||widthRes|| ' ' ||heigtRes);

    -- Propriétés de l'emplacement de l'image de gauche
    propLeft := ordsys.ord_str_list(
                 'position_x=0',
                 'position_y=0',
                 'transparency=1');


    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(backgroundImage1,TRUE, DBMS_LOB.SESSION);

    -- Ajout de l'image de gauche sur l'image de fond
    ORDSYS.ORDImage.applyWatermark(background, p_imageLeft, backgroundImage1, loggingLeft, propLeft);

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

    -- Propriétés de l'emplacement de l'image de droite
    propRight := ordsys.ord_str_list(
                 'position_x='||widthImgLeft,
                 'position_y=0',
                 'transparency=1');

    -- Ajout de l'image de droite sur l'image de fond qui contient déjà l'image de gauche
    ORDSYS.ORDImage.applyWatermark(backgroundImage1, p_imageRight, res, loggingRight, propRight);

      return res;
    end pastSide;

-- ###

  function GitHubProfil return blob AS
    background blob;
    square blob;
    res blob;
    logging VARCHAR2(2000);
    prop ordsys.ord_str_list;
    valRandom number;
    posX number;
    posY number;
    miroir blob;
    resDemi blob;
  begin

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

    -- Création de l'image dans le blob
    background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

    -- Ajustement des dimensions de l'image résultat divisé par deux sur la largeur
    ORDSYS.ORDIMAGE.process(background,'fixedScale=210 420');

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(square,TRUE, DBMS_LOB.SESSION);

    -- Création de l'image dans le blob
    square := hextoraw('89504E470D0A1A0A0000000D494844520000003C0000003C0802000000B59E4E25000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC546000000284944415478DAECC18100000000C3A0F9535FE0085501000000000000000000C037000000FFFF03002A6C0001753351590000000049454E44AE426082');

    -- Ajustement des dimensions des carrés noirs
    ORDSYS.ORDIMAGE.process(square,'fixedScale=60 60');

    -- boucle de remplissage sur la hauteur
    FOR i IN 0 .. 5 LOOP

      -- boucle de remplissage sur la largeur
      FOR j IN 0 .. 2 LOOP

        -- selection d'un nombre aléatoir entre 1 et 0
        select  round(dbms_random.value(0,1)) into valRandom from dual;

        -- Dans la moitié des possibilités
        if valRandom = 1 then

          -- On défini la position x
         posX:=60*j +30;

          --  On défini la positon y
         posY:=60*i +30;

        -- Propriétés de l'emplacement des carrés noirs
          prop := ordsys.ord_str_list(
                       'position_x='||posX,
                       'position_y='||posY,
                       'transparency=1');

           -- Initialisation du BLOB
           DBMS_LOB.CREATETEMPORARY(resDemi,TRUE, DBMS_LOB.SESSION);

           -- Ajout de d'un carré noir sur le fond
           ORDSYS.ORDImage.applyWatermark(background, square, resDemi, logging, prop);

           -- ORDSYS.ORDImage.applyWatermark ne pouvant modifier l'image courante reçue en paramètre on va l'affecter dans une variable tampon
           background:=resDemi;
         end if;

      END LOOP;
    END LOOP;

     -- Initialisation du BLOB
     DBMS_LOB.CREATETEMPORARY(miroir,TRUE, DBMS_LOB.SESSION);

     -- Effet miroir sur l'image de base
    ORDSYS.ORDIMAGE.processCopy(resDemi,'mirror', miroir);

     -- Initialisation du BLOB
     DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Collage côte a côte de l'image et son miroire pour un effet visuel agréable
     res:=pastSide(resDemi,miroir);

    return res;
  end GitHubProfil;

-- ###

   function addBorderTop(p_image blob, p_top number) return blob AS
     obj ordsys.ordimage;
     width number;
     height number;
     background blob;
     res blob;
     logging VARCHAR2(2000);
     prop ordsys.ord_str_list;
   begin

    -- Transformation du BLOB en type ORDImage
    obj := ORDSYS.ORDImage(p_image,1);

    -- Récupération de la hauteur de l'image actuel + la taille de la nouvelle bordure
    height := obj.getHeight() + p_top;

    -- Récupération de la largeur de l'image actuel
    width := obj.getWidth();

    -- Initialisation du BLOB
    DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

    -- Création de l'image dans le blob
    background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

    -- Ajustement des dimensions du masque de fond
    ORDSYS.ORDIMAGE.process(background,'fixedScale='||width||' '||height);

    -- Propriétés de l'emplacement de l'image dans le nouveau background avec le décalage en y
      prop := ordsys.ord_str_list(
                   'position_x=0',
                   'position_y='||p_top,
                   'transparency=1');

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

     -- Ajout de de l'image sur le background de la nouvelle taille pour simuler une bordure
     ORDSYS.ORDImage.applyWatermark(background, p_image, res, logging, prop);

    return res;
   end addBorderTop;

-- ###

    function addBorderBottom(p_image blob, p_bottom number) return blob AS
      obj ordsys.ordimage;
      width number;
      height number;
      background blob;
      res blob;
      logging VARCHAR2(2000);
      prop ordsys.ord_str_list;
    begin

     -- Transformation du BLOB en type ORDImage
     obj := ORDSYS.ORDImage(p_image,1);

     -- Récupération de la hauteur de l'image actuel + la taille de la nouvelle bordure
     height := obj.getHeight() + p_bottom;

     -- Récupération de la largeur de l'image actuel
     width := obj.getWidth();

     -- Initialisation du BLOB
     DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

     -- Création de l'image dans le blob
     background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

     -- Ajustement des dimensions du masque de fond
     ORDSYS.ORDIMAGE.process(background,'fixedScale='||width||' '||height);

     -- Propriétés de l'emplacement de l'image dans le nouveau background
       prop := ordsys.ord_str_list(
                    'position_x=0',
                    'position_y=0',
                    'transparency=1');

       -- Initialisation du BLOB
       DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

      -- Ajout de de l'image sur le background de la nouvelle taille pour simuler une bordure
      ORDSYS.ORDImage.applyWatermark(background, p_image, res, logging, prop);

     return res;
    end addBorderBottom;

-- ###

    function addBorderLeft(p_image blob, p_left number) return blob AS
       obj ordsys.ordimage;
       width number;
       height number;
       background blob;
       res blob;
       logging VARCHAR2(2000);
       prop ordsys.ord_str_list;
    begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel + la taille de la nouvelle bordure
      height := obj.getHeight();

      -- Récupération de la largeur de l'image actuel
      width := obj.getWidth() + p_left;

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

      -- Création de l'image dans le blob
      background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

      -- Ajustement des dimensions du masque de fond
      ORDSYS.ORDIMAGE.process(background,'fixedScale='||width||' '||height);

      -- Propriétés de l'emplacement de l'image dans le nouveau background
        prop := ordsys.ord_str_list(
                     'position_x='||p_left,
                     'position_y=0',
                     'transparency=1');

        -- Initialisation du BLOB
        DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

       -- Ajout de de l'image sur le background de la nouvelle taille pour simuler une bordure
       ORDSYS.ORDImage.applyWatermark(background, p_image, res, logging, prop);

      return res;
    end addBorderLeft;

-- ###

    function addBorderRight(p_image blob, p_right number) return blob AS
       obj ordsys.ordimage;
       width number;
       height number;
       background blob;
       res blob;
       logging VARCHAR2(2000);
       prop ordsys.ord_str_list;
     begin

      -- Transformation du BLOB en type ORDImage
      obj := ORDSYS.ORDImage(p_image,1);

      -- Récupération de la hauteur de l'image actuel + la taille de la nouvelle bordure
      height := obj.getHeight();

      -- Récupération de la largeur de l'image actuel
      width := obj.getWidth() + p_right;

      -- Initialisation du BLOB
      DBMS_LOB.CREATETEMPORARY(background,TRUE, DBMS_LOB.SESSION);

      -- Création de l'image dans le blob
      background := hextoraw('89504E470D0A1A0A0000000D4948445200000005000000050802000000020DB1B2000000097048597300000B1300000B1301009A9C18000000206348524D00007A25000080830000F9FF000080E9000075300000EA6000003A980000176F925FC5460000001B4944415478DA62FCFFFF3F031260624005A4F201000000FFFF0300EAF60307980CB10E0000000049454E44AE426082');

      -- Ajustement des dimensions du masque de fond
      ORDSYS.ORDIMAGE.process(background,'fixedScale='||width||' '||height);

      -- Propriétés de l'emplacement de l'image dans le nouveau background
        prop := ordsys.ord_str_list(
                     'position_x=0',
                     'position_y=0',
                     'transparency=1');

        -- Initialisation du BLOB
        DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

       -- Ajout de de l'image sur le background de la nouvelle taille pour simuler une bordure
       ORDSYS.ORDImage.applyWatermark(background, p_image, res, logging, prop);

      return res;
     end addBorderRight;

-- ###

     function addBorder(p_image blob, p_top number, p_bottom number, p_left number,  p_right number) return blob AS
       res blob;
     begin

       -- Initialisation du BLOB
       DBMS_LOB.CREATETEMPORARY(res,TRUE, DBMS_LOB.SESSION);

       -- Ajout de la bordure du haut
       res := addBorderTop(p_image, p_top);

       -- Ajout de la bordure du bas
       res := addBorderBottom(res, p_bottom);

       -- Ajout de la bordure de gauche
       res := addBorderLeft(res, p_left);

       -- Ajout de la bordure du haut
       res := addBorderRight(res,p_right);

       return res;

     end addBorder;
end pkg_ordimage_DJ;
/
