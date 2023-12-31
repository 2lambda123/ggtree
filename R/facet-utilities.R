##' function to relable selected panels created by 'geom_facet' or 'facet-plot'
##'
##' 
##' @title facet_labeller
##' @param p facet_plot output
##' @param label new labels of facet panels
##' @return ggplot object
##' @importFrom ggplot2 as_labeller
##' @export
##' @author Guangchuang Yu
facet_labeller <- function(p, label) {
    ## .panel <- panel_col_var(p)
    ## lbs <- panel_col_levels(p)
    lbs  <-  levels(p$data$.panel)
    names(lbs)  <-  lbs
    label <- label[names(label) %in% lbs]
    lbs[names(label)]  <-  label

    panel_labeller <- function(variable, value) {
        return(lbs[value])
    }

    p + facet_grid(cols=vars(factor(.data$.panel, levels=levels(p$data$.panel))),
                   scales="free_x",labeller = as_labeller(lbs))
}



##' set relative widths (for column only) of facet plots
##'
##' 
##' @title facet_widths
##' @param p ggplot or ggtree object
##' @param widths relative widths of facet panels
##' @return ggplot object by redrawing the figure (not a modified version of input object)
##' @author Guangchuang Yu
##' @export
##' @importFrom ggplot2 ggplot_gtable
##' @importFrom rlang check_installed
facet_widths <- function(p, widths) {
    if (!is.null(names(widths))) {
        ## if (is.ggtree(p) && !is.null(names(widths))) {
        ## .panel <- levels(p$data$.panel)
        .panel <- panel_col_levels(p)
        w <- rep(1, length=length(.panel))
        names(w) <- .panel
        w[names(widths)] <- widths
        widths <- w
    }
    gt  <- ggplot_gtable(ggplot_build(p))
    ## for(i in seq_along(widths)) {
    ##     j <- gt$layout$l[grep(paste0('panel-1-', i), gt$layout$name)]
    ##     gt$widths[j] = widths[i] * gt$widths[j]
    ## }
    ## j <- gt$layout$l[grep('panel-', gt$layout$name)]
    ## issue: https://github.com/YuLab-SMU/ggtree/issues/459
    j <- gt$layout$l[grep('panel-1-', gt$layout$name)]    
    gt$widths[j] <- gt$widths[j] * widths
    check_installed('ggplotify', 'for `facet_widths()`.')
    return(ggplotify::as.ggplot(gt))
}

panel_col_var <- function(p) {
    m <- p$facet$params$cols[[1]]
    if (is.null(m))
        return(m)

    ## rlang::quo_name(m)
    rlang::quo_text(m) %>%
        sub(",.*", "", .) %>%
        sub(".*\\(", "", .) %>%
        sub(".data\\$", "", .)
}

panel_col_levels <- function(p) {
    levels(p$data[[panel_col_var(p)]])
}

##' @importFrom ggplot2 facet_grid vars
##' @importFrom rlang .data
add_panel <- function(p, panel) {
    df <- p$data
    if (is.null(df[[".panel"]])) {
        df[[".panel"]] <- factor("Tree")
    }
    levels(df$.panel) %<>% c(., panel)
    p$data <- df
    #p + facet_grid(.~.panel, scales="free_x")
    p + facet_grid(cols=vars(factor(.data$.panel, levels=levels(df$.panel))),
                   scales="free_x")
}

