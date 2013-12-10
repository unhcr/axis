module 'Output',
  setup: () ->
    Visio.manager = new Visio.Models.Manager()

test 'budget', () ->
  o = new Visio.Models.Output(
    id: 'ben'
    name: 'lisa'
    aol_staff_budget: 10
    ol_staff_budget: 20
    aol_project_budget: 5
    ol_project_budget: 10
    aol_partner_budget: 30
    ol_partner_budget: 40
  )

  budget = o.budget()
  strictEqual budget, 115

  Visio.manager.get('scenerio_type')[Visio.Scenerios.OL] = false

  budget = o.budget()
  strictEqual budget, 45

  Visio.manager.get('budget_type')[Visio.Budgets.STAFF] = false
  budget = o.budget()
  strictEqual budget, 35
