# Rscript Report Automated Generation

AutomaticReportGen <- function(outbursttracker,childcheckins){
  library(ggplot2)
  library(scales)
  library(lubridate)
  outbreak_level=read.csv(outbursttracker)
  childcheckins=read.csv(childcheckins)
  #get times
  Time=outbreak_level$Time
  times.am=grep("*AM", Time)
  times.pm=grep("*PM", Time)
  stats_am = table(times.am)
  stats_pm = table(times.pm)
  #plots 
  df.am <- data.frame(Time=names(stats_am), Usage=as.vector(stats_am))
  df.pm <- data.frame(Time=names(stats_pm), Usage=as.vector(stats_pm))
  ggplot(df.am, aes(x=Time, y=Usage)) + geom_bar(stat='identity', fill="#f6ec64") + 
    theme_light() + coord_polar(start=285/57.2957795, clip="off") + 
    theme(axis.text.y=element_blank(), axis.ticks.y=element_blank(), 
          axis.title.x=element_text(size=20, face="bold"), 
          axis.text.x = element_text(size=18, face="bold"), 
          panel.border = element_blank()) + 
    xlab("Outbursts AM")+ ylab("")
  ggsave("am.png")
  
  ggplot(df.pm, aes(x=Time, y=Usage)) + geom_bar(stat='identity', fill="#ff9e03") + 
    theme_light() + coord_polar(start=285/57.2957795, clip="off") + 
    theme(axis.text.y=element_blank(), axis.ticks.y=element_blank(), 
          axis.title.x=element_text(size=20, face="bold"), 
          axis.text.x = element_text(size=18, face="bold"), 
          panel.border = element_blank()) + xlab("Outbursts AM")+ ylab("")
  ggsave("pm.png")
  ## timeline plots
  existing_labels = unique(outbreak_level$type)
  timeline_plot<-ggplot(outbreak_level,aes(x=dates,y=positionality, col=location, label=type))
  timeline_plot<-timeline_plot+labs(col="Type") + geom_hline(yintercept=0)
  timeline_plot<-timeline_plot+scale_color_manual(values=outbreak_level_type, 
                                                  labels=existing_labels, 
                                                  drop = FALSE)
  timeline_plot<-timeline_plot+theme_classic() +
    theme(axis.text.x =element_blank(),
          axis.line.x =element_blank(),
          axis.ticks.x = element_blank(),
          axis.line.y=element_blank(),
          axis.ticks.y=element_blank(),
          axis.text.y=element_text(size=12)
    ) + ylab("Location") + xlab("") +
    scale_y_continuous(breaks = -2:2, labels = location_labs)
  
  
  # Plot horizontal black line for timeline
  timeline_plot<-timeline_plot+ geom_point(aes(size = intensity), alpha = 0.5) +
    geom_text(data = M_df, aes(x=month_date_range, y=-0.2, label=day_format),
              size=10,vjust=0.5, color='black', angle=90) + 
    scale_size(range = c(5, 20)) +
    geom_text(data = M_df, aes(x=month_date_range, y= -0.5, label=month_format,
                               fontface="bold"),size=7.5, color='black')
  ggsave("timeline.png")
  
  
  
}