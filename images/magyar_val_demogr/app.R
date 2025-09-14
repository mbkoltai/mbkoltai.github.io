library(shiny); library(ggplot2); library(ggh4x); library(dplyr)

# load your precomputed list of dataframes
l_plot <- readRDS("l_plot_21kut_median.RDS")

ui <- fluidPage(
  tags$div(
  style = "border: 3px solid #ccc; padding: 10px 10px 0px 10px; margin-top: 10px; 
    border-radius: 10px; width: 700px; font-size: 18px;",
  selectInput("dataset", "ADATFORRÁS:", 
              choices = c("21 Kutatóközpont (2025/[04/06/08])" = "21_kut",
                          "MEDIÁN (2025/08)" = "median")) ),
  # text
  div(
      style="border: 3px solid #ccc; padding: 10px 10px 10px 10px; margin-top: 10px; 
              font-size: 16px;",  # növeli a szöveg méretét
  HTML("Válassz egy adatforrást a fenti menüből, és az ábra automatikusan frissül. <br> <br>
      MEGJEGYZÉSEK</b>: Az ábrák a 21kutatóintézet és a Medián 2025 nyári 
      méréseit integrálják a KSH demográfiai adataival. <br> 
      A függőleges tengelyen a választók száma ezerben van megadva. <br>
      <b>FONTOS</b>: Még ha a felmérések nagyon pontosak is lennének, a hibahatár így alkategóriánként nézve szinte
      biztosan nagyobb, mint a teljes mintára nézve. <br> 
      Tehát az oszlopok fölötti számokat, amelyek (ha abszolút számként kérjük őket) tízezerrel kerekítve lettek, 
      nem érdemes pontos becsléseknek venni. Ehelyett csak azt mutatják meg, 
      hogy hány (százalék) szavazó lenne az adott kategóriában, 
      <b>ha</b> a mérés tökéletesen pontos lenne - ami szinte biztosan nem igaz. <br>
      Ugyanakkor annyit megmutatnak, hogy az egyes demográfiai csoportokban 
      (pl. szakmunkás végzettségűek, 65 év felettiek stb.) összesen mennyien vannak, 
      illetve, ha a mérések hozzávetőlegesen pontosak, akkor azt is, hogy körülbelül hogyan oszlik el a 
      népesség pártszimpátia szerint. <br>
      Bizonyos demográfiai adatoknál (mint pl. a 74 éven felüliek végzettség szerinti eloszlása) 
      szintén feltételezésekkel kellett élnem, mivel nem teljesek a KSH-nál megtalálható adatok. <br>
      Erről további információ a projekt github-ján érhető el, az ábrákhoz használt csv táblázatokkal együtt: 
      "), 
    style = "width: 80%; margin-bottom: 30px;"),
   # new input: label type
  wellPanel(
  style="border: 3px solid #ccc; padding: 10px 10px 10px 10px; margin-top: 10px;width: 60%;",  
  radioButtons("label_type", "Címkék típusa:",
               choices = c("Abszolút szám"="abs", "Százalék" = "pct"),
               inline = T) ),
  
  plotOutput("mainplot", width="96%", height = "800px")
)

server <- function(input, output, session) {
  output$mainplot <- renderPlot({
      # choose dataset
    dat <- if (input$dataset == "21_kut") l_plot$`21_kut` else l_plot$median
    
    # compute percentages if needed
    
    # base plot
    p <- dat %>%
      ggplot(aes(x = partnev_kozos, y = valasztok_szama / 1e3, fill = datum)) +
      facet_manual(vars(kateg_nev_meret_str), scales = "free", 
                   design = if (input$dataset == "21_kut") {"AAAA \n BCDE \n FGHI"} else
                             {"AA### \n BBCC# \n DEFGH \n IJKL# \n MNOOP"} ) +
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
      scale_y_continuous(expand=expansion(mult=c(0.005,0.16))) +
      expand_limits(y=c(0,1100)) +
      # , # limits = function(x) c(0, max(max(x/1e3), 1.1e3))
      ggtitle(if (input$dataset == "21_kut") 
                { "Választók száma teljes népesség, végzettség és településtípus szerint - 21 Kutatóközpont" }
              else {
                "Választók száma teljes népesség, végzettség és településtípus szerint - MEDIÁN"} ) +
      theme_bw() + l_plot$standard_theme +
      theme(axis.text.x=element_text(vjust=0.5, hjust = 1),
            strip.text=element_text(size=18),legend.position="top")
    
  }, # render plot
  height = function() {
    # adapt height to ~70% of browser window height
    session$clientData$output_mainplot_width
  })
  
}

shinyApp(ui, server)


    # if (input$dataset == "21_kut") {
    #   l_plot$`21_kut` %>%
    #     ggplot(aes(x=partnev_kozos, y=valasztok_szama/1e3, fill=datum)) +
    #     facet_manual(vars(kateg_nev_meret_str), scales="free", design="AAA#\nBCDE\nFGHI") +
    #     geom_col(position=position_dodge2(), alpha=0.5, color="black", linewidth=1/3) +
    #     labs(x="", y="szavazók száma (ezer)", fill="") +
    #     geom_text(aes(label=round(valasztok_szama/1e4)*10),
    #       position=position_dodge2(width=0.9, preserve="single"),
    #       vjust=-0.3, size=4) +
    #     scale_y_continuous(expand=expansion(mult=c(0.005,0.09)),
    #                        limits=function(x) c(0, max(max(x),1.05e3))) +
    #     ggtitle("Választók száma teljes népesség, végzettség és településtípus szerint - 21 Kutatóközpont") +
    #     theme_bw() + l_plot$standard_theme +
    #     theme(axis.text.x=element_text(vjust=0.5,hjust=1),
    #           strip.text=element_text(size=18))
    # } else {
    #   l_plot$median %>%
    #     ggplot(aes(x=partnev_kozos, y=valasztok_szama/1e3, fill=datum)) +
    #     facet_manual(vars(kateg_nev_meret_str), scales="free",
    #                  design="AA### \n BC### \n DEFGH \n IJKL# \n MNOP#") +
    #     geom_col(position=position_dodge2(), alpha=0.5, color="black", linewidth=1/3) +
    #     labs(x="", y="szavazók száma (ezer)", fill="") +
    #     geom_text(aes(label=round(valasztok_szama/1e4)*10),
    #       position=position_dodge2(width=0.9, preserve="single"),
    #       vjust=-0.3,size=4) +
    #     scale_y_continuous(expand=expansion(mult=c(0.005,0.11)),
    #                        limits=function(x) c(0, max(max(x),1.05e3)) ) +
    #     ggtitle("Választók száma teljes népesség, végzettség és településtípus szerint - MEDIÁN") +
    #     theme_bw() + l_plot$standard_theme +
    #     theme(axis.text.x=element_text(angle=0),
    #           strip.text=element_text(size=18),
    #           legend.position="NULL")
    # }
    