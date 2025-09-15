library(shiny); library(ggplot2); library(ggh4x); library(dplyr); library(stringr)


# load your precomputed list of dataframes
l_plot <- readRDS("l_plot_21kut_median.RDS")

ui <- fluidPage(
  
  title = "2025 közvéleménykutatások + demográfia",   # <- this sets the browser tab title
  
  tags$head(
    tags$style(HTML("body, .shiny-text-output, .shiny-input-container {
        font-family: Calibri, Arial, sans-serif;} ")) ),
  
  tags$div(
  style = "border: 2px solid #ccc; border-radius: 10px; padding: 10px;
           width: 90%; margin: 10px auto; text-align: center; background-color: #f9f9f9;",
  tags$h1(
  style = "font-family: Calibri; font-size: 30px; word-wrap: break-word; white-space: normal; line-height: 1.2;",
  HTML("2025 magyarországi közvéleménykutatások rávetítése az országos demográfiára:<br>
       teljes népesség | nem | kor | végzettség | településméret") )
), 
  
  tags$div(
  style = "border: 3px solid #ccc; padding: 10px 10px 0px 10px; margin-top: 10px; 
    border-radius: 10px; width: 55%; font-size: 18px;",
  selectInput("dataset", "ADATFORRÁS:", 
              choices = c("21 Kutatóközpont (2025/[04/06/08])" = "21_kut",
                          "MEDIÁN (2025/08)" = "median"),
            width = "80%" ) ),
   # new input: label type
  wellPanel(
  style="border: 3px solid #ccc; padding: 10px 10px 10px 10px; margin-top: 10px; font-size: 16px; width: 60%;",  
  radioButtons("label_type", "Címkék típusa:",
               choices = c("abszolút szám (ezer)"="abs", "százalék" = "pct"),
               inline = T) ),
  # text
  tags$div(
  HTML("MEGJEGYZÉSEK</b>: Az ábrák a 21Kutatóközpont és a Medián 2025 nyári 
      méréseit integrálják a KSH demográfiai adataival. 
      Minden demográfiai adat a választásra jogosult, tehát 18 éves vagy idősebb, népességre vonatkozik, 
      ami a KSH 2025 évi becslése szerint kb. 7.88 millió ember. <br> 
      A függőleges tengelyen a választók száma ezerben van megadva. <br>
      <b>FONTOS</b>: Még ha a felmérések nagyon pontosak is (lennének), a hibahatár így, alkategóriánként nézve, szinte
      biztosan nagyobb, mint a teljes mintára nézve. <br>
      Tehát az oszlopok fölötti számokat, amelyek (ha abszolút számként kérjük őket) tízezerre kerekítve lettek, 
      nem érdemes pontos becsléseknek venni. Ehelyett csak azt mutatják meg, 
      hogy hány (százalék) szavazó lenne az adott kategóriában, 
      <b>ha</b> a mérés tökéletesen pontos lenne - ami szinte biztosan nem igaz. <br>
      Ugyanakkor annyit megmutatnak, hogy az egyes demográfiai csoportokban 
      (pl. szakmunkás végzettségűek, 65 év felettiek stb.) összesen mennyien vannak, 
      illetve, <i>ha</i> a mérések hozzávetőlegesen pontosak, akkor azt is, hogy körülbelül hogyan oszlik el a 
      népesség pártszimpátia szerint az adott kategóriákban. 
      Az utóbbi (ti. a kategóriákon belüli pártpreferencia eloszlás) valószínűleg jelentős(ebb) hibákat tartalmaz. <br>
      A 74 éven felüliek végzettség szerinti eloszlására nem találtam adatot a KSH-nál 
      (csak a 15-74 közötti népességre van meg). 
      Ezért itt (≥74) azt feltételeztem, hogy a végzettség szerinti megoszlás megfelel a legkorábbi adatpont (2009) 
      <i>teljes</i> lakosságra vonatkozó adataival.
      Emellett, a KSH felnőtt népesség adata kb. 120 ezerrel nagyobb, mint a 2022-es települési választási adatokból 
      kivonható adat. Ennek nem vagyok benne biztos, hogy mi az oka (talán a nem bejelentett külföldön élők). 
      További információ a 
      <a href='https://github.com/mbkoltai/mbkoltai.github.io/blob/source/images/magyar_val_demogr/script.R' 
      target='_blank'>projekt github-ján</a> érhető el, az ábrákhoz használt csv táblázatokkal együtt.
      Ez a két demográfiai pontatlanság nem változtat sokat (valószínűleg kb. néhány tízezret) 
      a végzettség és településtípus szerinti demográfiai csoportok méretén. <br>
      A MEDIÁN 2002 óta készült választás előtti - az eredményekkel összehasonlított - előrejelzéseit 
      <a href='https://docs.google.com/spreadsheets/d/1NUEgN7eV7MoZqi8dd9-xAzWxY_u2u_HYImV6l_U5qDE/' 
      target='_blank'>itt gyűjtöttem össze</a>. <br>
      A 21Kutközpont 2024-es 
      <a href='https://mbkoltai.com/ep2024-hungary-datavis/' target='_blank'>EP-választások</a>
      előtti (gyakorlatilag tökéletesre sikerült) 
      <a href='https://24.hu/belfold/2024/06/09/ep-valasztas-2024-exit-poll-mandatumbecsles/' 
      target='_blank'> előrejelzése itt</a>. <br>
      A többi közvéleménykutató demográfiai lebontást általában nem publikál, 
      illetve a <i> record</i>-juk annyira ellentmodásos, hogy inkább nem használtam őket."
      ), 
      style = "border: 3px solid #ccc; padding: 10px; margin-top: 10px; 
             font-size: 16px; width: 80%; margin-left: auto; 
              margin-right: auto; margin-bottom: 30px;"    ),
  # MAIN PLOT
  plotOutput("mainplot", width="96%") # , height = "800px"
)

server <- function(input, output, session) {
  output$mainplot <- renderPlot({
      # choose dataset
    dat <- if (input$dataset == "21_kut") {l_plot$`21_kut`} else {l_plot$median}
    
    # compute percentages if needed
    
    # base plot
    p <- dat %>%
      mutate(kateg_nev_meret_str = factor(str_wrap(kateg_nev_meret_str, width=10)) ) %>%
      ggplot(aes(x = partnev_kozos, y = valasztok_szama / 1e3, fill = datum)) +
      facet_manual(vars(kateg_nev_meret_str), scales = "free", 
                   design = if (input$dataset == "21_kut") {"AAAA \n BCDE \n FGHI"} else
                             {"AA### \n BBCC# \n DEFGH \n IJKL# \n MNOP#"} ) +
      geom_col(position = position_dodge2(), alpha = 0.5, color = "black", linewidth = 1/3) +
      labs(x = "", y = "szavazók száma (ezer)", fill = "")
    
    # conditional geom_text
    if (input$label_type == "abs") {
      p <- p + geom_text(aes(label=paste0(round(valasztok_szama/1e4)*10,"e")),
                         position = position_dodge2(width=0.9, preserve = "single"),
                         vjust = -0.3, size =4.5)
    } else {
      p <- p + geom_text(aes(label = paste0(arány*100,"%")),
                         position=position_dodge2(width=0.9,preserve="single"),
                         vjust = -0.3, size=4.5)
    }
    
    # remaining plot elements
    p + # 
      scale_y_continuous(expand=expansion(mult=c(0.005,0.2))) +
      expand_limits(y=c(0,1100)) +
      ggtitle(if (input$dataset == "21_kut") { "21 Kutatóközpont" } else { "MEDIÁN"} ) +
      theme_bw() + l_plot$standard_theme +
      theme(axis.text.x=element_text(vjust=0.5, hjust = 1),
            strip.text=element_text(size=18),
            legend.position="top")
    
  }
    , # render plot
  # height = function() {
  #   # adapt height to ~70% of browser window height
  #   session$clientData$output_mainplot_width
  # }
  height = function() {
  if (input$dataset == "21_kut") {
    session$clientData$output_mainplot_width*1.2
  } else {
    session$clientData$output_mainplot_width*1.75
  }
}
    
    )
}

shinyApp(ui, server)
