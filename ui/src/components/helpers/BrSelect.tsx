import React from "react";
import Select from 'react-select';
import { PlaySound, Sounds } from "../../helpers/SoundHelper";

const selectStyle = {
    container: (provided: any, state: any) => {
        return {
            ...provided, 
            marginBottom: '0',
            outline: 'none',
        };
    },
    control: (provided: any) => ({
        ...provided,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        borderRadius: 0,
        width: "auto",
        border: '0.05vw solid rgba(250, 246, 246, 0.6)',
        '&:hover': {
            borderColor: '#d5dde5',
        },
        minHeight: 0,
        height: '3.703703703703704vh',
        boxShadow: "none",
    }),
    singleValue: (provided: any) => ({
        ...provided,
        color: '#d5dde5',
        fontWeight: 400,
        fontSize: '0.8vw',
    }),
    option: (provided: any, state: any) => {
        let backgroundColor = 'transparent';
        let color = '#fff';
        let fontWeight = 300;

        if (state.isFocused && !state.isSelected)
        {
            backgroundColor = 'rgba(255, 255, 255, 0.2)';
        }
        else if (state.isSelected)
        {
            backgroundColor = 'rgba(255, 255, 255, 0.8)';
            color = '#000';
            fontWeight = 500;
        }

        return {
            ...provided,
            backgroundColor,
            color,
            fontWeight,
            fontSize: '0.8vw', // 20px
            padding: '0.7407407407407407vh 1.111111111111111vh', // 8px 12px,
            margin: 0,
        };
    },
    menu: (provided: any) => ({
        ...provided,
        backgroundColor: 'rgba(0, 0, 0, 0.8)',
        willChange: 'top',
        borderRadius: 0,
        boxShadow: 'none',
        border: '0.05vw solid rgba(250, 246, 246, 0.6)',
        zIndex: '999',
        margin: '.25vw 0 0',
        padding: 0,
    }),
    menuList: (provided: any) => ({
        ...provided,
        paddingTop: 0,
        paddingBottom: 0,
     }),
    dropdownIndicator: (provided: any) => ({
        ...provided,
        padding: '0.7407407407407407vh', // 8px
        svg: {
            height: '1.851851851851852vh', // 20px
            width: '1.851851851851852vh', // 20px
        },
    }),
    indicatorSeparator: (provided: any) => ({
        ...provided,
        display: 'none',
        width: '0.1574074074074074vh', // 1.7px
        marginTop: '0.7407407407407407vh', // 8px
        marginBottom: '0.7407407407407407vh', // 8px
    }),
    valueContainer: (provided: any) => ({
        ...provided,
        padding: '0 0.7407407407407407vh', // 0 8px
        height: '3.546296296296296vh', // 38.3px
    }),
};

interface Props {
    options: any;
    onChangeSelected: (selected: string) => void;
    selectValue: any;
}

const BrSelect: React.FC<Props> = ({ options, onChangeSelected, selectValue }) => {
    const handleChange = (event: any) => {
        PlaySound(Sounds.Click);
        onChangeSelected(event.value);
    }

    return (
        <>
            <Select 
                options={options} 
                styles={selectStyle} 
                isSearchable={false}
                value={selectValue}
                onChange={handleChange}
            />
        </>
    );
};

export default BrSelect;
