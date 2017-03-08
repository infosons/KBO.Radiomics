modelRadiomicaResults<- function(input,output,session,status) {
  
  ns<-session$ns
  
  selectDone<-function(fields,postFix) {
    query<-sprintf("SELECT %s FROM Radiomica_RUN WHERE status='done' %s",paste(fields,collapse=","),postFix)
    executeQuery(query)
  }
  
  getClinicalDati<-reactive({
    tableEvents[["DatoClinico"]]
    tableEvents[["DatoClinico_Paziente"]]
    query<-"SELECT dc.nome,dcp.id_paziente,dcp.valore FROM DatoClinico_Paziente dcp
    INNER JOIN DatoClinico dc ON dcp.id_dato_clinico=dc.id WHERE dcp.id_dato_clinico IN
    (SELECT id_dato_clinico FROM (SELECT DISTINCT id_dato_clinico, count(id_dato_clinico) as cnt 
    FROM DatoClinico_Paziente WHERE id_paziente in (SELECT DISTINCT id_paziente FROM Radiomica_Run) 
    GROUP BY id_dato_clinico) WHERE  cnt=(SELECT count(DISTINCT id_paziente) FROM Radiomica_Run))
    AND dc.tipo='Numeric' AND dcp.id_paziente in (SELECT DISTINCT id_paziente FROM Radiomica_Run) 
    ORDER BY dc.io, dcp.id_paziente"
    executeQuery(query)
  })
  
  getData<-function(rows) {
    for (i in xrange(nrow(rows))) {
      ogg<-unserialize(charToRaw(rows[["data"]][[i]]))
      rows[["data"]][[i]]=ogg
    }
    rows
  }
  
  results<-reactive({
    status$done
    output<-list()
    rows<-selectDone(c("id_paziente","roi","filtro","sigma","data"),"ORDER BY roi,filtro,sigma,id_paziente")
    rows=getData(rows)
    paziente_names=executeQuery("SELECT p.patient_name FROM Radiomica_Run rr INNER JOIN Paziente p ON p.id=rr.id_paziente
                                GROUP BY rr.id_paziente ORDER BY rr.id_paziente")[["patient_name"]]
    for (feature in moddicomV2::RAD.getFeaturesListNames()) {
      for (i in xrange(nrow(rows))) {
        row<-rows[i,]
        filter<-sprintf("%s.sigma.%s",row[["filtro"]],row[["sigma"]])
        key<-paste(gsub(" ", "", feature, fixed = TRUE),row[["roi"]],filter,sep=".")
        output[[key]]<-c(output[[key]],row[["data"]][[1]]$result[[feature]])
      }
    }
    datiClinici<-getClinicalDati()
    for (i in xrange(nrow(datiClinici))) {
      dc_nome<-datiClinici[["nome"]][i]
      output[[dc_nome]]<-c(output[[dc_nome]],as.numeric(datiClinici[["valore"]][i]))
    }
    dataframeOutput<-as.data.frame(output,row.names=paziente_names)
    colnames(dataframeOutput)<-names(output)
    dataframeOutput
  })
  
  output$csv=downloadHandler("results.csv",function(file) {
    write.csv(results(), file)
  })
  
  output$table=DT::renderDataTable(DT::datatable({
    results()
  },options = list(scrollX = TRUE)))
  
  return(results)
}
