class Visio.Views.IsyView extends Visio.Views.AccordionIndexView

  showView: (options) -> new Visio.Views.IsyShowView(options)

  id: 'isy'

  humanName: 'Single Indicator Year Results'

  sort: (parameterA, parameterB) ->
    dataA = parameterA.selectedIndicatorData()
    dataB = parameterB.selectedIndicatorData()

    analysisA = dataA.situationAnalysis()
    analysisB = dataB.situationAnalysis()

    if analysisA.result != analysisB.result
      return analysisB.result - analysisA.result
    else if analysisA.total != analysisB.total
      return analysisB.total - analysisA.total

    dataB.length - dataA.length
