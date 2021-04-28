import { LightningElement, api, track } from 'lwc';
import getHierarchy from '@salesforce/apex/CustomTreeController.getHierarchy';

export default class CustomTree extends LightningElement {
    @api recordId;
    @api label;
    @api parentField;
    @api fieldString;
    @api imageField;

    @track items = [];
    @track fields = [];
    @track actions;
    @track rootItem;
    @track rendered = false;
    @track searchText;
    @track trickleAction;

    sublabelDelimiter = ' - ';
    dragState;

    rootActions = [
        {
            name: 'openToCurrent',
            icon: 'utility:home',
            title: 'Open to current record'
        },
        {
            name: 'expandAll',
            icon: 'utility:expand',
            title: 'Expand all'
        },
        {
            name: 'collapseAll',
            icon: 'utility:contract',
            title: 'Collapse all'
        }
    ];

    connectedCallback() {
        if (!this.recordId) {
            console.log('Error: record ID not found');
            return;
        }
        console.log('in customTree connectedCallback');

        this.fieldString = this.fieldString.replace(/\s/g, '');

        getHierarchy({ recordId: this.recordId, parentField: this.parentField, fieldString: this.fieldString, imageField: this.imageField })
            .then(result => {
                //console.log('result returned', JSON.stringify(result));
                this.items = [];
                this.fields = this.fieldString.split(',');
                if (this.fields.length <= 0) {
                    console.log('Error: at least one field name is required');
                    return;
                }
                //console.log('actions', JSON.stringify(result.actions));
                this.actions = result.actions;
                this.rootItem = this.getItemFromRecord(result.rootRecord, null);
                this.items.push(this.rootItem);
                let parentLevel = this.items;
                for (let level of result.masterList) {
                    let nextParentLevel = [];
                    for (let [parentId, recordList] of Object.entries(level)) {
                        for (let record of recordList) {
                            let currentParent = parentLevel.find(el => {
                                return el.value === record[this.parentField];
                            });
                            let newItem = this.getItemFromRecord(record, currentParent);
                            //newItem.actions = result.actions;   // 7/7/20 adding the object's PlatformActions
                            //console.log('newItem actions', newItem.actions);
                            //if (record.Id === this.recordId)
                                //newItem.current = true;
                            currentParent.items.push(newItem); // add item to it's parent's list of children items
                            nextParentLevel.push(newItem);  // add item to the next level of items to process
                        }
                    }
                    parentLevel = nextParentLevel;
                }
                this.rendered = true;
                console.log('rendered customTree successfully');
            })
            .catch(error => {
                console.log('error', error);
            })
    }


    getItemFromRecord(record, parent) {
        let level = parent ? parent.level + 1 : 1;  // we start at 1 because that's what the aria-level in the child component expects
        let matchValues = [];
        for (let field of this.fields) {
            matchValues.push(record[field]);
        }
        return {
            label: record[this.fields[0]],
            value: record.Id,
            metatext: this.getMetatext(record),
            parent: parent,
            items: [],
            level: level,
            matchValues: matchValues,
            image: record[this.imageField],
            current: record.Id === this.recordId,
            actions: this.actions
            //record: record,
            //expanded: false
        }
    }

    getMetatext(record) {
        if (this.fields.length <= 1)
            return null;

        let metatext = '';        
        for (let i = 1; i < this.fields.length; i++) {
            if (record[this.fields[i]]) {
                metatext += (metatext ? this.sublabelDelimiter : '') + record[this.fields[i]];
            }
        }
        return metatext;
    }

    handleTrickleAction(event) {
        console.log('in trickleAction');
        console.log('action name = ' + event.target.name);
        this.trickleAction = event.target.name;
        this.template.querySelector('lightning-input').value = null;
        this.searchText = null;
    }

    handleSearch(event) {
        console.log('in handlesearch');
        console.log(event.target.value);
        this.searchText = event.target.value.toLowerCase();
    }


    ifBlank(obj, replacementVal) {
        return obj ? obj : replacementVal;
    }


    handleChildDrag(event) {
        console.log('in root drag');
        this.dragState = event.detail.value;
        console.log('dragState', this.dragState);
    }

    /*
    bubbleUp(item, func, excludeCurrent) { this.bubble2(item, 'up', func, excludeCurrent) }
    bubbleDown(item, func, excludeCurrent) { this.bubble2(item, 'down', func, excludeCurrent) }
    bubble2(item, direction, func, excludeCurrent) {
        //console.log('in bubble2', item.label);
        if (!excludeCurrent) {
            func(item);
        }
        if (direction === 'up' && item.parent)
            this.bubble2(item.parent, direction, func);
        if (direction === 'down' && item.items.length > 0) {
            for (let child of item.items) {
                this.bubble2(child, direction, func);
            }
        }
    }

    bubble(item, direction, properties, values, excludeCurrent) {

        properties = Array.isArray(properties) ? properties : [properties];
        values = Array.isArray(values) ? values : [values];
        if (properties.length !== values.length) {
            console.log('Error in bubble, properties and values must have equal number of items');
        }

        if (!excludeCurrent) {
            for (let i = 0; i < properties.length; i++) {
                console.log(item[properties[i]], '=', values[i]);
                item[properties[i]] = values[i];
            }
        }

        if (direction === 'up' && item.parent) {
            this.bubble(item.parent, direction, properties, values);
        }
        if (direction === 'down' && item.items) {
            for (let child of item.items) {
                this.bubble(child, direction, properties, values);
            }
        }
    }
    */
}