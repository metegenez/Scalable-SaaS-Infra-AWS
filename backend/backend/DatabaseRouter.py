class AuroraRouter:
    """
    Because Aurora separates the storage layer from the db instances,
    no synchronization (ie migrations) between readonly db instances and the cluster
    instance needs to be done.
    """
    route_app_labels = {'app_name'}

    def db_for_read(self, model, **hints):
        return "readonly"

    def db_for_write(self, model, **hints):
        return "default"

    def allow_relation(self, obj1, obj2, **hints):
        return None

    def allow_migrate(self, db, app_label, model_name=None, **hints):
        return None