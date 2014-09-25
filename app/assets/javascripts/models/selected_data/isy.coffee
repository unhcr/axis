class Visio.SelectedData.Isy extends Visio.SelectedData.Base


  formattedIds: ->

    ids =
      operation_ids: [@get('d').get('operation_id')]
      ppg_ids: [@get('d').get('ppg_id')]
      goal_ids: [@get('d').get('goal_id')]
      problem_objective_ids: [@get('d').get('problem_objective_id')]

    ids
